variable "name" {}
variable "env_prefix" {}
variable "region" {}
variable "cpu" {}
variable "memory" {}

variable "app_image" {}
variable "app_log_driver" {}

variable "app_log_options" {
  type = map
}

variable "app_enviroment" {
  type = list
}

variable "app_secrets" {
  type = list
}
variable app_workdir {}
variable "requires_compatibilities" {
  type    = list
  default = []
}

variable "command" {
  type    = list(string)
  default = ["sh", "-c", "python manage.py"]
}

variable "network_mode" {
  default = "brigde"
}

variable "static_bucket_arn" {}

variable "dns_servers" {
  type = list
}

