variable "name" {}

variable "host_port" {
  default = 0
}

variable "cluster_id" {}
variable "task_arn" {}

variable "desired_count" {
  default = 1
}

variable "launch_type" {
  default = "FARGATE"
}

variable "service_type" {
  default = "WEB"
}

variable "target_group_arn" {
  default = ""
}

variable "alb_link_container_name" {
  default = "nginx"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "scheduling_strategy" {
  default = "REPLICA"
}

variable "health_check_grace_period_seconds" {
  default = 10
}
