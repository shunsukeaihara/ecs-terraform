
resource "aws_alb_target_group" "this" {
  name                 = var.name
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay
  target_type          = var.target_type

  health_check {
    interval            = var.health_check["interval"]
    path                = var.health_check["path"]
    port                = 80
    protocol            = "HTTP"
    timeout             = var.health_check["timeout"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    matcher             = var.health_check["matcher"]
  }

  tags = {
    Name = var.name
    Made = "terraform"
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = var.listener_arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.domains
    }
  }
}

