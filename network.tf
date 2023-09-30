module "mynetwork" {
  source               = "./network"
  region               = var.region
  
  vpc_cidr             = var.vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnets_cidr  = var.public_subnets_cidr_blocks
  private_subnets_cidr = var.private_subnets_cidr_blocks
}
