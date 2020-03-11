resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "${var.name}-alb"
  vpc_id      = var.vpc_id

  #ingress {
  #    from_port   = 80
  #    to_port     = 80
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }


  #ingress {
  #  from_port        = 80
  #    to_port          = 80
  #    protocol         = "tcp"
  #    ipv6_cidr_blocks = ["::/0"]
  #  }

  #ingress {
  #    from_port   = 443
  #    to_port     = 443
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #ingress {
  #  from_port        = 443
  #    to_port          = 443
  #    protocol         = "tcp"
  #    ipv6_cidr_blocks = ["::/0"]
  #  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.name}-alb"
    Made = "terraform"
  }
}

resource "aws_security_group_rule" "inbound_rules" {
  count             = length(var.inbound_rules)
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  cidr_blocks = [lookup(var.inbound_rules[count.index], "cidr_blocks")]
  protocol    = lookup(var.inbound_rules[count.index], "protocol")
  from_port   = lookup(var.inbound_rules[count.index], "from_port", 80)
  to_port     = lookup(var.inbound_rules[count.index], "to_port", 80)
}
