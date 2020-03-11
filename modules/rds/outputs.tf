output "address" {
  value = aws_db_instance.this.address
}

output "password" {
  value     = random_string.password.result
  sensitive = true
}

output "username" {
  value     = random_string.username.result
  sensitive = true
}

output "sg_id" {
  value = aws_security_group.this.id
}
