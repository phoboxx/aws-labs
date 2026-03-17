

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
  default_tags {
    tags = {
      Project  = "vprofile"
      Deployed = "terraform"
    }
  }
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

# Create SSH key-pair 
# name: vprofile-PROD-KEY
resource "aws_key_pair" "vprofile_prod_key" {
  key_name   = "vprofile-PROD-KEY"
  public_key = var.vprofile_prod_public_key
}


# Name: vprofile-db01
# AMI: Amazon Linux 2023
# Type: t2.micro
# SSH-Key-PAIR
# SG: vprofile-BACKEND-SG
# Networking: Auto-assign public IP
# USER DATA: mysql.sh
# TESTING: 
#   - systemctl status mariadb
#   - mysql -u admin -p accounts
#   - show tables;
module "ec2_instance_vprofile_db01" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "vprofile-db01"
  ami                         = var.amazon_linux_2023_ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids      = [module.vprofile_backend_sg.security_group_id]
  monitoring                  = true
  subnet_id                   = aws_default_subnet.default_az1.id
  user_data                   = templatefile("${path.module}/user_data/mysql.sh.tftpl", { mysql_db_password = var.mysql_db_password })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"

  tags = {
    Name = "Default subnet for us-east-2a"
  }
}


# Name: vprofile-mc01
# AMI: Amazon Linux 2023
# Type: t2.micro
# SSH-Key-PAIR
# SG: vprofile-BACKEND-SG
# Networking: Auto-assign public IP
# USER DATA: memcache.sh
# TESTING:
#   - systemctl status memcached
module "ec2_instance_vprofile_mc01" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "vprofile-mc01"
  ami                         = var.amazon_linux_2023_ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids      = [module.vprofile_backend_sg.security_group_id]
  monitoring                  = true
  subnet_id                   = aws_default_subnet.default_az1.id
  user_data                   = file("${path.module}/user_data/memcache.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Name: vprofile-rmq01
# AMI: Amazon Linux 2023
# Type: t2.micro
# SSH-Key-PAIR
# SG: vprofile-BACKEND-SG
# Networking: Auto-assign public IP
# USER DATA: rabbitmq.sh
# TESTING:
#   - systemctl status rabbitmq-server
module "ec2_instance_vprofile_rmq01" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "vprofile-rmq01"
  ami                         = var.amazon_linux_2023_ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids      = [module.vprofile_backend_sg.security_group_id]
  monitoring                  = true
  subnet_id                   = aws_default_subnet.default_az1.id
  user_data                   = file("${path.module}/user_data/rabbitmq.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Name: vprofile-app01
# AMI: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
# Type: t2.micro
# SSH-Key-PAIR
# SG: vprofile-APP-SG
# Networking: Auto-assign public IP
# USER DATA: tomcat_ubuntu.sh
module "ec2_instance_vprofile_vprofile_app01" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "vprofile-app01"
  ami                         = var.ubuntu_24_04_ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids      = [module.vprofile_app_sg.security_group_id]
  monitoring                  = true
  subnet_id                   = aws_default_subnet.default_az1.id
  user_data                   = file("${path.module}/user_data/tomcat_ubuntu.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# TODO: TAG Instances, Volumes
# TODO: Output all servers URLs
# TODO: Testing you can ssh to all instances
# TODO: Use templatefile instead of a file to avoid hardcoding secrets
