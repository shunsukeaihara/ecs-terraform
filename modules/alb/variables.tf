variable "name" {
  description = "env-projectname-appname"
}

variable "tg_name" {}

variable "domains" {
  type    = list(string)
  default = []
}

variable "vpc_id" {}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable inbound_rules {
  type = list(object({
    cidr_blocks = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))

  default = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    },
  ]
}

variable "target_type" {}

variable "health_check" {
  type = map

  default = {
    interval            = 30
    path                = "/"
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
  default = "ELBSecurityPolicy-FS-1-1-2019-08"
}
