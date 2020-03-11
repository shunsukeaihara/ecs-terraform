locals {
  instnace_count = var.replica_scale_enabled ? var.replica_scale_min + 1 : var.replica_count + 1
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name
  database_name      = var.dbname
  engine             = var.engine
  engine_version     = var.engine_version

  # availability_zones = "${var.availability_zones}"

  master_username                 = var.dbusername
  master_password                 = var.dbpassword
  port                            = var.port
  backup_retention_period         = var.backup_retention_period
  preferred_maintenance_window    = var.maintenance_window
  preferred_backup_window         = var.backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = "${var.name}-final-snapshot"
  storage_encrypted               = var.storage_encrypted
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  tags = {
    Name = var.name
    Made = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = local.instnace_count

  identifier                   = "${var.name}-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.this.id
  engine                       = var.engine
  engine_version               = var.engine_version
  preferred_maintenance_window = var.maintenance_window
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.this.name
  publicly_accessible          = var.publicly_accessible
  db_parameter_group_name      = aws_db_parameter_group.this.name
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade

  monitoring_role_arn = join("", aws_iam_role.monitoring.*.arn)
  monitoring_interval = var.monitoring_interval

  performance_insights_enabled = var.performance_insights_enabled
  apply_immediately            = var.apply_immediately

  promotion_tier = count.index

  tags = {
    Name = "${var.name}-${count.index + 1}"
    Made = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
