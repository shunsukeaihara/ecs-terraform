variable "env_prefix" {}
variable "cdir_block" {}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "single_nat_gateway" {
  default = false
}
