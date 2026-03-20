provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Project  = "vprofile"
      Deployed = "terraform"
    }
  }
}

module "compute" {
  source                   = "../../../modules/compute/"
  vprofile_prod_public_key = var.vprofile_prod_public_key
  mysql_db_password        = var.mysql_db_password
  s3_iam_role_name         = module.s3_iam_role.role_name
}


module "dns" {
  source = "../../../modules/dns"
  private_dns_records = [{
    dns_name   = "db01",
    private_ip = module.compute.ec2_instance_vprofile_db01_private_ip
    },
    {
      dns_name   = "mc01",
      private_ip = module.compute.ec2_instance_vprofile_mc01_private_ip
    },
    {
      dns_name   = "rmq01",
      private_ip = module.compute.ec2_instance_vprofile_rmq01_private_ip
    },
    {
      dns_name   = "app01",
      private_ip = module.compute.ec2_instance_vprofile_app01_private_ip
    }
  ]
  vpc_id           = module.compute.vpc_id
  vpc_region       = module.compute.vpc_region
  hosted_zone_name = var.hosted_zone_name
}

module "s3_iam_role" {
  source = "../../../modules/s3_iam_role"
}
