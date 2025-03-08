# =============================================================================
# ===== Variables =============================================================
# =============================================================================

variable "proxmox_host" {
  description = "Proxmox API Host. has to be in thr form IP:PORT."
  type        = string
}

variable "proxmox_node" {
  description = "Which node in the Proxmox cluster to start the virtual machine on during creation."
  type        = string
}

variable "proxmox_api_token_id" {
  description = "API Token ID."
  sensitive   = true
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "API Token Secret."
  sensitive   = true
  type        = string
}

variable "proxmox_ssk_private_key" {
  description = "The SSH private key to be used when connecting via SSH."
  sensitive   = true
  type        = string
}
