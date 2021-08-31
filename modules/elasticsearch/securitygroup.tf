resource "aws_security_group" "this" {
  name        = "${var.name}-elasticsearch"
  description = "${var.name}-elasticsearch"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-elasticsearch"
    Made = "terraform"
  }
}

resource "aws_security_group_rule" "inbound_rules" {
  count             = var.inbound_rule_count
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  source_security_group_id = lookup(var.inbound_rules[count.index], "sgid")
  protocol                 = lookup(var.inbound_rules[count.index], "protocol")
  from_port                = lookup(var.inbound_rules[count.index], "from_port", 80)
  to_port                  = lookup(var.inbound_rules[count.index], "to_port", 80)
}
