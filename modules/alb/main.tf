resource "aws_alb" "alb" {
  name                       = var.name
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnet_ids
  internal                   = false
  enable_deletion_protection = false

  tags = {
    Name = var.name
    Made = "terraform"
  }
}

resource "aws_alb_target_group" "this" {
  name                 = var.tg_name
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
    Name = var.tg_name
    Made = "terraform"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = var.ssl_policy

  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_certificate" "cert" {
  count           = length(var.optional_certificate_arns)
  listener_arn    = aws_alb_listener.https.arn
  certificate_arn = var.optional_certificate_arns[count.index]
}


resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_alb_listener.http.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  condition {
    host_header {
      values = var.domains
    }
  }
}

