variable "name" {}
variable "dbname" {}
variable "dbusername" {}
variable "dbpassword" {}

variable "engine" {
  default = "aurora-mysql"
}

variable "engine_version" {
  default = "5.7.12"
}

variable "family" {
  default = "aurora-mysql5.7"
}

variable "instance_class" {}

variable "availability_zones" {
  type    = "list"
  default = []
}

variable "vpc_id" {}

variable "db_subnet_ids" {
  type    = "list"
  default = []
}

variable "inbound_rule_count" {}

variable "inbound_rules" {
  type    = "list"
  default = []
}

variable "port" {
  default     = 3306
  description = "The port on which to accept connections"
}

variable "monitoring_interval" {
  description = "enhanced monitoring is disabled if set 0"
  default     = "10"
}

variable "maintenance_window" {
  default = "Mon:20:15-Mon:21:15"
}

variable "backup_window" {
  default = "19:00-20:00"
}

variable "skip_final_snapshot" {
  default = false
}

variable "backup_retention_period" {
  default = 7
}

variable "storage_encrypted" {
  default = false
}

variable "cluster_parameters" {
  type        = "list"
  description = "{name = name, value = value}"
  default     = []
}

variable "instance_parameters" {
  type        = "list"
  description = "{name = name, value = value}"
  default     = []
}

variable "replica_count" {
  default     = 1
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
}

variable "performance_insights_enabled" {
  default = false
}

variable "apply_immediately" {
  default     = false
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
}

variable "publicly_accessible" {
  default = false
}

variable "auto_minor_version_upgrade" {
  default = true
}

// autoscaling

variable "replica_scale_enabled" {
  default = false
}

variable "replica_scaling_policy" {
  default     = "StepScaling"
  description = "TargetTrackingScaling or StepScaling, default is StepScaling"
}

variable "replica_scale_max" {
  default = 2
}

variable "replica_scale_min" {
  default = 1
}

variable "replica_scale_value" {
  default     = 70
  description = "using when replica_scaling_policy is set to TargetTrackingScaling"
}

variable "replica_cpu_high_thresold" {
  default     = 70
  description = "used when replica_scaling_policy is set to StepScaling"
}

variable "replica_cpu_low_thresold" {
  default     = 30
  description = "used when replica_scaling_policy is set to StepScaling"
}

variable "replica_scale_in_cooldown" {
  default = 300
}

variable "replica_scale_out_cooldown" {
  default = 300
}
