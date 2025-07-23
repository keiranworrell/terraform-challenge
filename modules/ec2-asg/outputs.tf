output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.auto_scaling_group.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.launch_template.id
}
