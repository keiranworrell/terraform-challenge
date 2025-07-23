resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "db" {
  identifier              = var.name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids  = var.security_group_ids
  name                    = var.name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  multi_az                = false
  publicly_accessible     = false

  tags = var.tags
}
