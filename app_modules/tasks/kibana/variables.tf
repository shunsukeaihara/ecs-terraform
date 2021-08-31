variable "name" {}
variable "env_prefix" {}
variable "region" {}
variable "cpu" {}
variable "memory" {}

variable "elasticsearch_host" {}

variable "nginx_image" {}
variable "log_driver" {}

variable "log_options" {
  type = "map"
}

variable "kibana_image" {
}

variable "nginx_host_port" {
  default = 0
}

variable "requires_compatibilities" {
  type    = "list"
  default = []
}

variable "kibana_command" {
  type    = "list"
  default = []
}

variable "oauth2proxy_command" {
  type    = "list"
  default = []
}

variable "network_mode" {
  default = "brigde"
}

variable "dns_servers" {
  type = "list"
}

variable "key_arn" {}

variable "oauth2_proxy_addr" {
  default     = "127.0.0.1:4180"
  description = "FARGATEの場合はlinkが使えないので127.0.0.1:4180を、それ以外はoauth2proxy:4180"
}
