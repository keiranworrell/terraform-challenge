terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source                = "./modules/network"
  vpc_cidr              = var.vpc_cidr
  name                  = var.name
  public_subnet_count   = var.public_subnet_count
  private_subnet_count  = var.private_subnet_count
  newbits               = var.newbits
  tags                  = local.tags
}
