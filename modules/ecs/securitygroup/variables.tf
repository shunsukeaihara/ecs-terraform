variable "name" {}
variable "vpc_id" {}

variable "inbound_rules" {
  type = list(object({
    sgid      = string
    from_port = number
    to_port   = number
    protocol  = string
  }))
  default = []
}
