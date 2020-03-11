variable "vpc_id" {}

variable "name" {}

variable "alb_arn" {}

variable "listener_arn" {}

variable "domains" {
  type    = list(string)
  default = []
}

variable "target_type" {}

variable "health_check" {
  type = map

  default = {
    interval            = 30
    path                = "/_ping"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

variable "deregistration_delay" {
  default = 60
}

variable "certificate_arn" {
  type = string
}

variable "optional_certificate_arns" {
  type    = list(string)
  default = []
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS-1-1-2017-01"
}
