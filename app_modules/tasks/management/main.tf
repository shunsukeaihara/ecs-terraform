data "aws_caller_identity" "self" {}

data "template_file" "task_policy" {
  template = file("${path.module}/templates/policy.tpl.json")

  vars = {
    static_bucket_arn = var.static_bucket_arn
    env_prefix        = var.env_prefix
    region            = var.region
    account_id        = data.aws_caller_identity.self.account_id
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = var.name
  path        = "/tasks/"
  description = var.name
  policy      = data.template_file.task_policy.rendered
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task"
  assume_role_policy = file("${path.module}/assume_role.json")
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_role" "task_exec_role" {
  name               = "${var.name}-task-exec"
  assume_role_policy = file("${path.module}/assume_role.json")
}

resource "aws_iam_role_policy_attachment" "exec_policy_attachment" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_rw_policy_attachement" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachement" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "template_file" "container_definitions" {
  template = file("${path.module}/../../templates/management_task.tpl.json")

  vars = {
    command         = jsonencode(var.command)
    app_image       = var.app_image
    app_log_driver  = var.app_log_driver
    app_log_options = jsonencode(var.app_log_options)
    app_enviroment  = jsonencode(var.app_enviroment)
    app_secrets     = jsonencode(var.app_secrets)
    dns_servers     = jsonencode(var.dns_servers)
    app_workdir     = var.app_workdir
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_exec_role.arn

  container_definitions = data.template_file.container_definitions.rendered
}
