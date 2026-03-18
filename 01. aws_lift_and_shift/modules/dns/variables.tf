variable "private_dns_records" {
  type = list(object({
    dns_name   = string,
    private_ip = string
  }))
  description = "This is a list of objects for all the DNS records to be created"
}

variable "hosted_zone_name" {
  type        = string
  description = "This is the hosted zone name"
  default     = "test-zone.com"
}

variable "vpc_id" {
  type = string
  description = "VPC id where the hosted zone will be accessible (only one is accepted for now)"
}

variable "vpc_region" {
  type = string
  description = "Region with there hosted zone will be accessible (only one is accepted for now)"
}