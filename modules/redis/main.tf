resource "aws_elasticache_subnet_group" "this" {
  name        = var.name
  description = var.name
  subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_parameter_group" "this" {
  name   = var.name
  family = var.family
  dynamic parameter {
    for_each = var.parameters
    content {
      name  = parameter.name
      value = parameter.value
    }
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.name
  replication_group_description = var.name
  engine                        = var.engine
  engine_version                = var.engine_version

  security_group_ids         = [aws_security_group.this.id]
  subnet_group_name          = aws_elasticache_subnet_group.this.id
  node_type                  = var.node_type
  number_cache_clusters      = var.number_cache_clusters
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.this.id
  automatic_failover_enabled = var.automatic_failover_enabled
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  maintenance_window         = var.maintenance_window

  tags = {
    Name = var.name
    Made = "terraform"
  }
}
