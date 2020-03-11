output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.this.primary_endpoint_address
}


output "sg_id" {
  value = aws_security_group.this.id
}
