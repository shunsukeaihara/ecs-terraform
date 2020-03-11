resource "aws_security_group" "this" {
  name        = "${var.name}-redis"
  description = "${var.name}-redis"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
    Made = "terraform"
  }
}

resource "aws_security_group_rule" "inbound_rules" {
  count             = length(var.inbound_rules)
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  source_security_group_id = lookup(var.inbound_rules[count.index], "sgid")
  protocol                 = lookup(var.inbound_rules[count.index], "protocol")
  from_port                = lookup(var.inbound_rules[count.index], "from_port", var.port)
  to_port                  = lookup(var.inbound_rules[count.index], "to_port", var.port)
}
