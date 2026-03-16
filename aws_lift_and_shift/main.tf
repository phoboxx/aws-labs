

# Create SSH key-pair 
# name: vprofile-PROD-KEY

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# vprofile-ELB-SG
# Description: Security Group for the vprofile load balancer
# Inbound rules: HTTP from IPV4 & IPV6
# Inbound rules: HTTPS from IPV4 & IPV6
module "vprofile_elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "vprofile-ELB-SG"
  description = "Security Group for the vprofile load balancer"
  vpc_id      = aws_default_vpc.default.id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
  ingress_ipv6_cidr_blocks = ["::/0"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

# vprofile-APP-SG
# Description: Security group for tomcat app server
# Inbound rules: 8080 from vprofile-ELB-SG
# inbound rules: SSH from MY IP
module "vprofile_app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "vprofile-APP-SG"
  description = "Security group for tomcat app server"
  vpc_id      = aws_default_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.vprofile_elb_sg.security_group_id
    },
  ]

  ingress_with_cidr_blocks = [{
    rule        = "ssh-tcp"
    cidr_blocks = "${local.my_local_ip}/32"
  }]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

}

# vprofile-BACKEND-SG
# Description: Security group for mysql, memcache & rabbitmq allowed from tomcat app server
# Inbound rules: 3306 (mysql) from vprofile-APP-SG
# Inbound rules: 11211 (memcache) from vprofile-APP-SG
# Inbound rules: 5672 (rabbitmq) from vprofile-APP-SG
# Inbound rules: SSH from MY IP
# Inbound rules: Allow all traffic from itself
module "vprofile_backend_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "vprofile-BACKEND-SG"
  description = "Security group for mysql, memcache & rabbitmq allowed from tomcat app server"

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.vprofile_app_sg.security_group_id
    },
    {
      rule                     = "memcached-tcp"
      source_security_group_id = module.vprofile_app_sg.security_group_id
    },
    {
      rule                     = "rabbitmq-5672-tcp"
      source_security_group_id = module.vprofile_app_sg.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.vprofile_backend_sg.security_group_id
      description              = "Allow traffic to flow bettween all backend servers"
    }
  ]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${local.my_local_ip}/32"
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

}
