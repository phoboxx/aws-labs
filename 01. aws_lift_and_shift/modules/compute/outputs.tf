output "ec2_instance_vprofile_db01_url" {
  value       = module.ec2_instance_vprofile_db01.public_dns
  description = "Public DNS address of vprofile-db01"
}

output "ec2_instance_vprofile_mc01_url" {
  value       = module.ec2_instance_vprofile_mc01.public_dns
  description = "Public DNS address of vprofile-mc01"
}

output "ec2_instance_vprofile_rmq01_url" {
  value       = module.ec2_instance_vprofile_rmq01.public_dns
  description = "Public DNS address of vprofile-rmq01"
}

output "ec2_instance_vprofile_app01_url" {
  value       = module.ec2_instance_vprofile_app01.public_dns
  description = "Public DNS address of vprofile-app01"
}

output "ec2_instance_vprofile_db01_private_ip" {
  value       = module.ec2_instance_vprofile_db01.private_ip
  description = "Private IP address of vprofile-db01"
}

output "ec2_instance_vprofile_mc01_private_ip" {
  value       = module.ec2_instance_vprofile_mc01.private_ip
  description = "Private IP address of vprofile-mc01"
}

output "ec2_instance_vprofile_rmq01_private_ip" {
  value       = module.ec2_instance_vprofile_rmq01.private_ip
  description = "Private IP address of vprofile-rmq01"
}

output "ec2_instance_vprofile_app01_private_ip" {
  value       = module.ec2_instance_vprofile_app01.private_ip
  description = "Private IP address of vprofile-app01"
}

output "vpc_id" {
  value       = aws_default_vpc.default.id
  description = "VPC id where the ressources are provisioned"
}

output "vpc_region" {
  value = data.aws_region.current.id
}

output "load_balancer_url" {
  value = module.alb.dns_name
}
