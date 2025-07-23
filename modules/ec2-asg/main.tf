resource "aws_launch_template" "launch_template" {
  name_prefix             = "${var.name}-lt"
  image_id                = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name != null ? var.key_name : null
  vpc_security_group_ids  = var.security_group_ids

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.name}-asg"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.subnets
  health_check_type         = "EC2"
  force_delete              = true
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
