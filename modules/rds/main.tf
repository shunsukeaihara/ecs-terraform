resource "random_string" "password" {
  length = 8
}

resource "random_string" "username" {
  length           = 8
  special          = true
  override_special = "-_"
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  storage_type              = var.storage_type
  iops                      = var.iops
  storage_encrypted         = false
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name}-final-snapshot"
  backup_retention_period   = var.backup_retention_period

  name     = var.dbname
  username = random_string.username.result
  password = random_string.password.result
  port     = var.dbport

  vpc_security_group_ids = [aws_security_group.this.id]
  maintenance_window     = var.maintenance_window
  backup_window          = var.backup_window

  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name = aws_db_parameter_group.this.name
  option_group_name    = aws_db_option_group.this.name

  tags = {
    Name = var.name
    Made = "terraform"
  }
}
