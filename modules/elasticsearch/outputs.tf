output "security_group_id" {
  value = aws_security_group.this.id
}

output "endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}

output "arn" {
  value = aws_elasticsearch_domain.this.arn
}
