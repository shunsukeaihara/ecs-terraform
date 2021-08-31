variable name {}
variable dist_bucket_arn {}
variable log_group_name {}

variable filter_pattern {
  default = ""
}

variable buffer_size {
  default = 10
}

variable buffer_interval {
  default = 300
}

variable number_of_retries {
  default = 3
}

variable lambda_memory_size {
  default = 128
}

variable lambda_timeout {
  default = 120
}

variable "es_format" {
  default = false
}

variable "buffer_size_in_mbs" {
  default = 3
}

variable "buffer_interval_in_seconds" {
  default = 120
}
