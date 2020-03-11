resource "aws_appautoscaling_target" "this" {
  count              = {var.replica_scale_enabled ? 1 : 0
  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

/*
resource "aws_appautoscaling_policy" "this" {
  count              = "${var.replica_scale_enabled && var.replica_scaling_policy == "TargetTrackingScaling" ? 1 : 0}"
  depends_on         = ["aws_appautoscaling_target.this"]
  name               = "${var.name}-autoscaling-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    scale_in_cooldown  = "${var.replica_scale_in_cooldown}"
    scale_out_cooldown = "${var.replica_scale_out_cooldown}"
    target_value       = "${var.replica_scale_value}"
  }
}
*/

resource "aws_appautoscaling_policy" "scale_out" {
  count              = var.replica_scale_enabled && var.replica_scaling_policy == "StepScaling" ? 1 : 0
  depends_on         = [aws_appautoscaling_target.this]
  name               = "${var.name}-scale-out"
  policy_type        = "StepScaling"
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.replica_scale_out_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_in" {
  count              = var.replica_scale_enabled && var.replica_scaling_policy == "StepScaling" ? 1 : 0
  depends_on         = [aws_appautoscaling_target.this]
  name               = "${var.name}-scale-in"
  policy_type        = "StepScaling"
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.replica_scale_in_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "high" {
  count               = var.replica_scale_enabled && var.replica_scaling_policy == "StepScaling" ? 1 : 0
  alarm_name          = "${var.name}-CPU-Utilization-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.replica_cpu_high_thresold

  dimensions {
    DBClusterIdentifier = aws_rds_cluster.this.cluster_identifier
    Role                = "READER"
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "low" {
  count               = var.replica_scale_enabled && var.replica_scaling_policy == "StepScaling" ? 1 : 0
  alarm_name          = "${var.name}-CPU-Utilization-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "180"
  statistic           = "Average"
  threshold           = var.replica_cpu_low_thresold

  dimensions {
    DBClusterIdentifier = {aws_rds_cluster.this.cluster_identifier
    Role                = "READER"
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in.arn]
}
