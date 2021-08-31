variable name {}

variable "vpc_id" {}

variable lambda_memory_size {
  default = 128
}

variable lambda_timeout {
  default = 120
}

variable log_group_name {}

variable log_group_arn {}

variable cloudwatch_logs_endpoint {
  default = "logs.ap-northeast-1.amazonaws.com"
}

variable "subnet_ids" {
  type = list(str)
}

variable "elasticsearch_endpoint" {}

variable "elasticsearch_arn" {}
