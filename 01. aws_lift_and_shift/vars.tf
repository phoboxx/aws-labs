variable "vprofile_prod_public_key" {
  type        = string
  description = "SSH public key to access instances in the lab"
  sensitive   = true
}

variable "amazon_linux_2023_ami_id" {
  type        = string
  description = "AMI ID for amazon linux 2023"
  default     = "ami-0b0b78dcacbab728f"
}

variable "mysql_db_password" {
  type        = string
  description = "MySQL db password for vprofile-db01"
  sensitive   = true
}
