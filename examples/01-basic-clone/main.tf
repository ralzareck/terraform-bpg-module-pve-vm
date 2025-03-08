# =============================================================================
# ===== Example - Basic Clone =================================================
# =============================================================================

# Minimum configuration required for successful clone of a Proxmox template.

module "pve_vm" {
  source = "../.."

  vm_type  = "clone"
  pve_node = var.proxmox_node

  src_clone = {
    datastore_id = "data"
    tpl_id       = 1000
  }

  vm_name = "example-basic"

  vm_bios = "ovmf"
  vm_efi_disk = {
    datastore_id = "data"
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
