output "target_group_id" {
  value = aws_alb_target_group.this.id
}

output "target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "target_group_arn_suffix" {
  value = aws_alb_target_group.this.arn_suffix
}
