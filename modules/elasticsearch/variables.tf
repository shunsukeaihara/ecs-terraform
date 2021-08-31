variable name {}

variable es_version {
  default = "6.3"
}

variable instance_type {
  default = "t2.small.elasticsearch"
}

variable "instance_count" {
  default = 1
}

variable "subnet_ids" {
  type = list(str)
}

variable "es_zone_awareness" {
  default = false
}

variable "vpc_id" {}

variable dedicated_master_enabled {
  default = false
}

variable dedicated_master_count {
  default = 0
}

variable dedicated_master_type {
  default = ""
}

variable encrypt_at_rest {
  default = false
}

variable snapshot_start_hour {
  default = 22
}

variable "ebs_volume_size" {
  default = 35
}

variable "ebs_volume_type" {
  default = "gp2"
}

variable "inbound_rules" {
  type    = list
  default = []
}

variable "inbound_rule_count" {
  default = 0
}
