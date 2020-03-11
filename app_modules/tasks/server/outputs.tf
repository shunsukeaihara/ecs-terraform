output "arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_json" {
  value = data.template_file.container_definitions.rendered
}

output "policy_json" {
  value = data.template_file.task_policy.rendered
}
