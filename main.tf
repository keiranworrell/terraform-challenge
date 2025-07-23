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

module "alb_sg" {
  source        = "./modules/security_group"
  name          = "${var.name}-alb-sg"
  ingress_rules = var.alb_ingress_rules
  vpc_id        = module.network.vpc_id
  tags          = local.tags
}

module "app_sg" {
  source        = "./modules/security_group"
  name          = "${var.name}-app-sg"
  ingress_rules = var.app-ingress_rules
  vpc_id        = module.network.vpc_id
  tags          = local.tags
}

module "rds_sg" {
  source        = "./modules/security_group"
  name          = "${var.name}-rds-sg"
  ingress_rules = var.rds-ingress_rules
  vpc_id        = module.network.vpc_id
  tags          = local.tags
}

module "alb" {
  source                = "./modules/alb"
  name                  = var.name
  vpc_id                = module.network.vpc_id
  subnets               = module.network.public_subnets
  security_group_ids    = module.alb_sg.security_group_id
  tags                  = local.tags
}


module "rds" {
  source              = "./modules/rds"
  name                = "${var.name}-rds"
  db_username         = var.db_username
  db_password         = var.db_password
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_storage
  vpc_id              = module.network.vpc_id
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.db_sg.id]
  tags = local.tags
}

module "ec2_asg" {
  source              = "./modules/ec2-asg"
  name                = var.name
  subnets             = module.network.public_subnets
  key_name            = var.ssh_key_name
  security_group_ids  = [module.app_sg.security_group_id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  user_data           = var.ec2_user_data
  target_group_arns   = module.alb.target_group_arn
  ami_id              = data.aws_ami.al2023.id
  tags                = local.tags
}


