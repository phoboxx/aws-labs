variable "vprofile_prod_public_key" {
  type        = string
  description = "SSH public key to access instances in the lab"
  sensitive   = true
}

variable "mysql_db_password" {
  type        = string
  description = "MySQL db password for vprofile-db01"
  sensitive   = true
}

variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone name where the records are going to be held"
}
