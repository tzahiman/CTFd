module "networking" {
  source = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "compute" {
  source           = "./modules/compute"
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_id
  security_group_id = module.networking.security_group_id
}