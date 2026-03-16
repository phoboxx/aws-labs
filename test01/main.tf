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

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = "t3.micro"
  monitoring    = true
  subnet_id     = aws_default_subnet.default_az1.id

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
