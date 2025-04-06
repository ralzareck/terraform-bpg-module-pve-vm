# Copyright 2025 RalZareck
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
