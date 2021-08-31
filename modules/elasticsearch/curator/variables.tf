variable name {}

variable "vpc_id" {}

variable lambda_memory_size {
  default = 128
}

variable lambda_timeout {
  default = 120
}

variable "subnet_ids" {
  type = list(str)
}

variable "elasticsearch_endpoint" {}

variable "elasticsearch_arn" {}

variable "rotation_period" {
  default = 40
}
