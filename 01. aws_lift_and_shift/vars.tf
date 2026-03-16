variable "vprofile_prod_public_key" {
  type        = string
  description = "SSH public key to access instances in the lab"
  sensitive   = true
}
