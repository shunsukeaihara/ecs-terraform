resource "aws_db_subnet_group" "this" {
  name        = var.name
  description = var.name
  subnet_ids  = [var.db_subnet_ids]

  tags {
    Name = var.name
    Made = "terraform"
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = var.name
  description = var.name
  family      = var.family

  parameter = [var.cluster_parameters]

  tags {
    Name = var.name
    Made = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "this" {
  name        = var.name
  description = var.name
  family      = var.family

  parameter = [var.instance_parameters]

  tags {
    Name = var.name
    Made = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
