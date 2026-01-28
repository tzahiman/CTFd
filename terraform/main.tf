module "networking" {
  source = "./modules/networking"
  vpc_cidr = var.vpc_cidr
}

module "compute" {
  source           = "./modules/compute"
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_id
  security_group_id = module.networking.security_group_id
}