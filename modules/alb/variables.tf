variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to deploy ALB into"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the ALB"
  type        = list(string)
  default     = []
}

variable "target_group_port" {
  description = "Port on which the target group receives traffic"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for the target group (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
