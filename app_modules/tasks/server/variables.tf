variable "name" {}
variable "env_prefix" {}
variable "region" {}
variable "cpu" {}
variable "memory" {}

variable "app_image" {}
variable "nginx_image" {}
variable "app_log_driver" {}

variable "app_log_options" {
  type = map
}

variable "nginx_log_driver" {}

variable "nginx_log_options" {
  type = map
}

variable app_workdir {}

variable "nginx_host_port" {
  default = 0
}

variable "app_enviroment" {
  type = list
}

variable "nginx_enviroment" {
  type = list
}

variable "app_secrets" {
  type = list
}

variable "requires_compatibilities" {
  type    = list
  default = []
}

variable "command" {
  type    = list(string)
  default = ["sh", "-c", "python manage.py XXXX"]
}

variable "nginx_command" {
  type = list
}
variable "network_mode" {
  default = "brigde"
}

variable "static_bucket_arn" {}

variable "dns_servers" {
  type = list
}

