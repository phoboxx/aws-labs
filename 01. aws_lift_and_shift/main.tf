module "compute" {
  source                   = "./modules/compute/"
  vprofile_prod_public_key = var.vprofile_prod_public_key
  mysql_db_password        = var.mysql_db_password
}
