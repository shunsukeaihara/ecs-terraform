output "security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_arn" {
  value = aws_alb.alb.arn
}

output "alb_arn_suffix" {
  value = aws_alb.alb.arn_suffix
}

output "alb_id" {
  value = aws_alb.alb.id
}

output "dns_name" {
  value = aws_alb.alb.dns_name
}

output "zone_id" {
  value = aws_alb.alb.zone_id
}

output "target_group_id" {
  value = aws_alb_target_group.this.id
}

output "target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "target_group_arn_suffix" {
  value = aws_alb_target_group.this.arn_suffix
}

output "https_listener_arn" {
  value = aws_alb_listener.https.arn
}
