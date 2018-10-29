variable "zone" {
  default     = "europe-west1-b"
  description = "zone for VM"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "db_ip_addr" {
  description = "mongodb internal ip"
}

variable "provisioner_condition" {
  description = "if it's equal 1, then exec provisioner"
}
