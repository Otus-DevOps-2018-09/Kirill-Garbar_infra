variable "zone" {
  default     = "europe-west1-b"
  description = "zone for VM"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "provisioner_condition" {
  description = "if it's equal 1, then exec provisioner"
}
