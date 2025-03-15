# =============================================================================
# ===== Example - Basic Clone =================================================
# =============================================================================

# Minimum configuration required for successful clone of a Proxmox template.

module "pve_vm" {
  source = "../.."

  vm_type  = "image"
  pve_node = var.proxmox_node

  src_file = {
    datastore_id = "image"
    file_name    = "noble-server-cloudimg-amd64.img"
  }

  vm_name = "example-basic"

  vm_bios = "ovmf"
  vm_efi_disk = {
    datastore_id = "data"
  }

  vm_disk = {
    scsi0 = {
      datastore_id = "data"
      size         = 8
      main_disk    = true
    }
  }

  vm_net_ifaces = {
    net0 = {
      bridge    = "vmbr0"
      ipv4_addr = "10.0.0.1/24"
      ipv4_gw   = "10.0.0.1"
    }
  }

  vm_init = {
    datastore_id = "local"
    interface    = "ide0"
  }
}
