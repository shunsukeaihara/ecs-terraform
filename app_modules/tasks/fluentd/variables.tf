variable "firehose_arns" {
  type = "list"
}

variable "image" {}

variable "dns_servers" {
  type    = "list"
  default = []
}

variable "log_driver" {}

variable "log_options" {
  type = "map"
}

variable "enviroment" {
  type = "list"
}
