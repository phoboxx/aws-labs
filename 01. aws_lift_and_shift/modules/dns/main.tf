# Create a Route 53 hosted zone (Private hosted zone)
terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.36.0"
    }
  }
}
module "zone" {
  source       = "terraform-aws-modules/route53/aws"
  name         = var.hosted_zone_name
  private_zone = true
  records = {
    for record in var.private_dns_records :
    record.dns_name => {
      type    = "A"
      ttl     = 3600
      records = [record.private_ip]
    }
  }

  vpc = {
    one = {
      vpc_id     = var.vpc_id
      vpc_region = var.vpc_region
    }
  }
}
