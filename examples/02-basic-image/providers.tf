# =============================================================================
# ===== Provider ==============================================================
# =============================================================================

terraform {
  required_version = "~> 1.9"
}

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66"
    }
  }
}

provider "proxmox" {
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  endpoint  = "https://${var.proxmox_host}/api2/json"
  insecure  = true
  ssh {
    agent       = false
    private_key = file(var.proxmox_ssk_private_key)
    username    = "root"
  }
}
