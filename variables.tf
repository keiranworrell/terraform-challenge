variable "name" {
  type        = string
  default     = "cint-code-test"
  description = "Root name for resources in this project"
}

variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC cidr block"
}

variable "newbits" {
  default     = 8
  type        = number
  description = "How many bits to extend the VPC cidr block by for each subnet"
}

variable "public_subnet_count" {
  default     = 3
  type        = number
  description = "How many subnets to create"
}

variable "private_subnet_count" {
  default     = 3
  type        = number
  description = "How many private subnets to create"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "alb_ingress_rules" {
  description = "Ingress rules for the ALB security group"
  type = list(object({
    from_port     = number
    to_port       = number
    protocol      = string
    cidr_blocks   = list(string)
    source_sg_ids = list(string)
    description   = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      source_sg_ids = []
      description = "Allow HTTP inbound"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      source_sg_ids = []
      description = "Allow HTTPS inbound"
    }
  ]
}

variable "app_ingress_rules" {
  description = "Ingress rules for the EC2 security group"
  type = list(object({
    from_port     = number
    to_port       = number
    protocol      = string
    cidr_blocks   = list(string)
    source_sg_ids = list(string)
    description   = string
  }))
  default = [
    {
      from_port     = 80
      to_port       = 80
      protocol      = "tcp"
      cidr_blocks   = []
      source_sg_ids = [module.alb_sg.security_group_id]
      description   = "Allow HTTP from ALB"
    }
  ]
}

variable "db_ingress_rules" {
  description = "Ingress rules for the EC2 security group"
  type = list(object({
    from_port     = number
    to_port       = number
    protocol      = string
    cidr_blocks   = list(string)
    source_sg_ids = list(string)
    description   = string
  }))
  default = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      cidr_blocks     = []
      source_sg_ids   = [module.app_sg.security_group_id]
      description     = "Allow MySQL from EC2 SG"
    }
  ]
}

variable "ec2_user_data" {
  description = "User data script for instance bootstrap"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    echo "DB_HOST=${module.rds.rds_endpoint}" >> /etc/environment
  EOF
}


variable "ssh_key_name" {
  description = "Key pair for SSH access to EC2 instances"
  type        = string
}

variable "rds_instance_class" {
  description = "Instance type for RDS"
  type        = string
}

variable "rds_storage" {
  description = "RDS storage in GB"
  type        = number
}

variable "environment" {
  description = "Type of environment"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}
