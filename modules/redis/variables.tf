variable "name" {}
variable "vpc_id" {}
variable "family" {}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "inbound_rules" {
  type = list(object({
    sgid      = string
    from_port = number
    to_port   = number
    protocol  = string
  }))
  default = []
}

variable "engine" {
  default = "redis"
}

variable "engine_version" {
  default = "4.0.10"
}

variable "node_type" {
  default = "cache.t2.micro"
}

variable "maintenance_window" {
  default = "Mon:20:15-Mon:21:15"
}

variable "snapshot_window" {
  default = "19:00-20:00"
}

variable "snapshot_retention_limit" {
  default = 7
}

variable "number_cache_clusters" {
  default = 1
}

variable "automatic_failover_enabled" {
  default = true
}

variable "port" {
  default = 6379
}
