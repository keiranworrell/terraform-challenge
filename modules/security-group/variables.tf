variable "name" {
  description = "Name for the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the SG will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
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
      cidr_blocks   = ["0.0.0.0/0"]
      source_sg_ids = []
      description   = "Allow HTTP inbound"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}
