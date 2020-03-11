variable "name" {}

variable "db_subnet_ids" {
  type    = list(string)
  default = []
}

variable "family" {}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  description = "{name = name, value = value, apply_method = apply_method}"
  default     = []
}

variable "engine" {}
variable "major_engine_version" {}

variable "options" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "{name = name, value = value}"
  default     = []
}

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

variable "engine_version" {}
variable "instance_class" {}

variable "storage_type" {
  type        = string
  description = "standard, gp2, io1"
}

variable "allocated_storage" {}
variable "dbname" {}

variable "dbport" {
  default = "5432"
}

variable "iops" {
  default = 0
}

variable "maintenance_window" {
  default = "Mon:20:15-Mon:21:15"
}

variable "backup_window" {
  default = "19:00-20:00"
}

variable "multi_az" {
  default = true
}

variable "skip_final_snapshot" {
  default = false
}

variable "backup_retention_period" {
  default = 7
}
