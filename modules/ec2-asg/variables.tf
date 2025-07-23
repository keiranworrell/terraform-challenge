variable "name" {
  description = "Name prefix for ASG and Launch Template"
  type        = string
}

variable "subnets" {
  description = "List of subnets for ASG"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "key_name" {
  description = "Key pair for SSH access"
  type        = string
}

variable "security_group_ids" {
  description = "List of Security Group IDs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Number of instances desired"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum size of ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of ASG"
  type        = number
  default     = 3
}

variable "user_data" {
  description = "User data script for instance bootstrap"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "target_group_arns" {
  description = "List of Target Group ARNs for ALB attachment"
  type        = list(string)
  default     = []
}
