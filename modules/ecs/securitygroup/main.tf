resource "aws_security_group" "cluster" {
  name        = var.name
  description = var.name
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
  security_group_id = aws_security_group.cluster.id
  type              = "ingress"

  from_port                = lookup(var.inbound_rules[count.index], "from_port")
  to_port                  = lookup(var.inbound_rules[count.index], "to_port")
  protocol                 = lookup(var.inbound_rules[count.index], "protocol")
  source_security_group_id = lookup(var.inbound_rules[count.index], "sgid")
}
