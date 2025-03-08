# =============================================================================
# = VM Creation ===============================================================
# =============================================================================

resource "proxmox_virtual_environment_vm" "pve_vm" {
  # Proxmox
  node_name = var.pve_node

  # VM Information
  name        = var.vm_name
  description = var.vm_description
  tags        = var.vm_tags
  vm_id       = var.vm_id
  pool_id     = var.vm_pool

  # Boot settings
  started = var.vm_start.on_deploy
  on_boot = var.vm_start.on_boot

  startup {
    order      = var.vm_start.order
    up_delay   = var.vm_start.up_delay
    down_delay = var.vm_start.down_delay
  }

  dynamic "clone" {
    for_each = (var.vm_type == "clone") ? ["enabled"] : []
    content {
      datastore_id = var.src_clone.datastore_id
      node_name    = (var.src_clone.node_name != null) ? var.src_clone.node_name : var.pve_node
      vm_id        = var.src_clone.tpl_id
      full         = true
    }
  }

  # VM Configuration
  operating_system {
    type = var.vm_os
  }

  bios          = (var.vm_type == "image") ? var.vm_bios : null
  machine       = (var.vm_type == "image") ? var.vm_machine : null
  scsi_hardware = (var.vm_type == "image") ? var.vm_scsi_hardware : null

  cpu {
    type  = var.vm_cpu.type
    cores = var.vm_cpu.cores
    units = var.vm_cpu.units
  }

  memory {
    dedicated = var.vm_mem.dedicated
    floating  = (var.vm_mem.floating != null) ? var.vm_mem.floating : var.vm_mem.dedicated
    shared    = var.vm_mem.shared
  }

  vga {
    type   = var.vm_display.type
    memory = var.vm_display.memory
  }

  dynamic "hostpci" {
    for_each = var.vm_pcie != null ? var.vm_pcie : {}
    content {
      device  = hostpci.key
      mapping = hostpci.value.name
      pcie    = hostpci.value.pcie
      xvga    = hostpci.value.primary_gpu
    }
  }

  dynamic "efi_disk" {
    for_each = (var.vm_bios == "ovmf") ? ["enabled"] : []
    content {
      datastore_id      = var.vm_efi_disk.datastore_id
      file_format       = var.vm_efi_disk.file_format
      type              = var.vm_efi_disk.type
      pre_enrolled_keys = var.vm_efi_disk.pre_enrolled_keys
    }
  }

  dynamic "disk" {
    for_each = (var.vm_type == "image") ? ["enabled"] : []
    content {
      interface    = var.vm_image_disk.interface
      datastore_id = var.vm_image_disk.datastore_id
      file_format  = var.vm_image_disk.file_format
      file_id      = "${var.src_file.datastore_id}:iso/${var.src_file.file_name}"
      # file_id      = (var.src_file.url == null) ? "${var.src_file.datastore_id}:iso/${var.src_file.file_name}" : proxmox_virtual_environment_download_file.vm_image[0].id
      size     = var.vm_image_disk.size
      iothread = var.vm_image_disk.iothread
    }
  }

  dynamic "disk" {
    for_each = (var.vm_type == "clone") ? var.vm_disk : {}
    content {
      interface    = disk.key
      datastore_id = disk.value.datastore_id
      file_format  = disk.value.file_format
      size         = disk.value.size
      iothread     = disk.value.iothread
    }
  }

  dynamic "network_device" {
    for_each = var.vm_net_ifaces
    content {
      bridge       = network_device.value.bridge
      disconnected = !network_device.value.enabled
      firewall     = network_device.value.firewall
      mac_address  = network_device.value.mac_addr
      model        = network_device.value.model
      mtu          = network_device.value.mtu
      rate_limit   = network_device.value.rate_limit
      vlan_id      = network_device.value.vlan_id
    }
  }

  initialization {
    datastore_id = var.vm_init.datastore_id
    interface    = var.vm_init.interface

    dynamic "ip_config" {
      for_each = var.vm_net_ifaces
      content {
        ipv4 {
          address = ip_config.value.ipv4_addr
          gateway = ip_config.value.ipv4_gw
        }
      }
    }

    dynamic "dns" {
      for_each = (var.vm_init.dns != null) ? ["enabled"] : []
      content {
        domain  = var.vm_init.dns.domain
        servers = var.vm_init.dns.servers
      }
    }

    dynamic "user_account" {
      for_each = (var.vm_init.user != null && var.vm_user_data == null) ? ["enabled"] : []
      content {
        username = var.vm_init.user.name
        password = var.vm_init.user.password
        keys     = var.vm_init.user.keys
      }
    }

    user_data_file_id = (var.vm_init.user == null && var.vm_user_data != null) ? var.vm_user_data : null

  }

  lifecycle {
    precondition {
      condition     = ((var.vm_init.user != null && var.vm_user_data == null) || (var.vm_init.user == null && var.vm_user_data != null) || (var.vm_init.user == null && var.vm_user_data == null))
      error_message = "Variables 'vm_init.user' and 'vm_user_data' are incompatible, only one should be set."
    }
  }
}

# =============================================================================
# = VM Firewall ===============================================================
# =============================================================================

resource "proxmox_virtual_environment_firewall_options" "pve_vm_fw_opts" {
  count = (var.vm_fw_opts != null) ? 1 : 0

  node_name = proxmox_virtual_environment_vm.pve_vm.node_name
  vm_id     = proxmox_virtual_environment_vm.pve_vm.vm_id

  enabled       = var.vm_fw_opts.enabled
  dhcp          = var.vm_fw_opts.dhcp
  input_policy  = var.vm_fw_opts.input_policy
  output_policy = var.vm_fw_opts.output_policy
  macfilter     = var.vm_fw_opts.macfilter
  ipfilter      = var.vm_fw_opts.ipfilter
}

resource "proxmox_virtual_environment_firewall_rules" "pve_vm_fw_rules" {
  count = (var.vm_fw_rules != null || var.vm_fw_group != null) ? 1 : 0

  node_name = proxmox_virtual_environment_vm.pve_vm.node_name
  vm_id     = proxmox_virtual_environment_vm.pve_vm.vm_id

  dynamic "rule" {
    for_each = var.vm_fw_rules != null ? var.vm_fw_rules : {}
    content {
      enabled = rule.value.enabled
      action  = rule.value.action
      type    = rule.value.direction
      iface   = rule.value.iface
      proto   = rule.value.proto
      source  = rule.value.srcip
      sport   = rule.value.srcport
      dest    = rule.value.destip
      dport   = rule.value.destport
      comment = "${rule.value.comment == null ? "" : rule.value.comment}; Managed by Terraform"
    }
  }

  dynamic "rule" {
    for_each = var.vm_fw_group != null ? var.vm_fw_group : {}
    content {
      enabled        = rule.value.enabled
      security_group = rule.key
      iface          = rule.value.iface
      comment        = "${rule.value.comment == null ? "" : rule.value.comment}; Managed by Terraform"
    }
  }
}
