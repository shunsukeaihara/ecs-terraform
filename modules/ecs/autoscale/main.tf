data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.tpl.sh")

  vars = {
    cluster_name = var.cluster_name
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.name}-"
  image_id                    = data.aws_ami.ecs_optimized.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.this.id
  key_name                    = var.key_name
  security_groups             = [var.security_group_id]
  associate_public_ip_address = 0
  user_data                   = data.template_file.user_data.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  lifecycle {
    create_before_destroy = true
  }
}

### Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  availability_zones        = [var.availability_zones]
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  launch_configuration      = aws_launch_configuration.this.id
  vpc_zone_identifier       = [var.subnet_ids]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag = {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
