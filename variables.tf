variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform version"
}

variable "node_name" {
  type        = string
  default     = "Proxmox Backup"
  description = "Name of EC2 instance"
}