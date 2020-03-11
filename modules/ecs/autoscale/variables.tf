variable "name" {}
variable "cluster_name" {}
variable "vpc_id" {}
variable "instance_type" {}

variable "availability_zones" {
  type    = "list"
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "subnet_ids" {
  type    = "list"
  default = []
}

variable "security_group_id" {}

variable "key_name" {}

variable "max_size" {
  default = 3
}

variable "min_size" {
  default = 1
}

variable "desired_capacity" {
  default = 2
}
