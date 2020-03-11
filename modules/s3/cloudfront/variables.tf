variable name {}
variable region {}

variable allow_origins {
  type    = list(string)
  default = []
}

variable "domain" {}
variable "cert_arn" {}
