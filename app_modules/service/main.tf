resource "aws_iam_role" "this" {
  name               = "${var.name}-service"
  assume_role_policy = file("${path.module}/assume_role.json")
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_ecs_service" "fargate" {
  count           = var.launch_type == "FARGATE" && var.service_type == "WEB" ? 1 : 0
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.task_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.alb_link_container_name
    container_port   = var.host_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "ec2" {
  count               = var.launch_type == "EC2" && var.service_type == "WEB" ? 1 : 0
  name                = var.name
  cluster             = var.cluster_id
  task_definition     = var.task_arn
  desired_count       = var.desired_count
  iam_role            = aws_iam_role.this.arn
  launch_type         = "EC2"
  scheduling_strategy = var.scheduling_strategy

  health_check_grace_period_seconds = 10

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.alb_link_container_name
    container_port   = var.host_port
  }
}

resource "aws_ecs_service" "ec2_worker" {
  count               = var.launch_type == "EC2" && var.service_type == "WORKER" ? 1 : 0
  name                = var.name
  cluster             = var.cluster_id
  task_definition     = var.task_arn
  desired_count       = var.desired_count
  launch_type         = "EC2"
  iam_role            = aws_iam_role.this.arn
  scheduling_strategy = var.scheduling_strategy

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "fargate_worker" {
  count           = var.launch_type == "FARGATE" && var.service_type == "WORKER" ? 1 : 0
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.task_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }
}
