locals {
  fargate_arn  = var.service_type == "WEB" ? join("", aws_ecs_service.fargate.*.id) : join("", aws_ecs_service.fargate_worker.*.id)
  ec2_arn      = var.service_type == "WEB" ? join("", aws_ecs_service.ec2.*.id) : join("", aws_ecs_service.ec2_worker.*.id)
  fargate_name = var.service_type == "WEB" ? join("", aws_ecs_service.fargate.*.name) : join("", aws_ecs_service.fargate_worker.*.name)
  ec2_name     = var.service_type == "WEB" ? join("", aws_ecs_service.ec2.*.name) : join("", aws_ecs_service.ec2_worker.*.name)
}

output "arn" {
  value = var.launch_type == "EC2" ? local.ec2_arn : local.fargate_arn
}

output "name" {
  value = var.launch_type == "EC2" ? local.ec2_name : local.fargate_name
}
