data "aws_caller_identity" "self" {}

data "template_file" "task_policy" {
  template = "${file("${path.module}/templates/policy.tpl.json")}"

  vars = {
    env_prefix = "${var.env_prefix}"
    region     = "${var.region}"
    account_id = "${data.aws_caller_identity.self.account_id}"
    key_arn    = "${var.key_arn}"
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = "${var.name}"
  path        = "/tasks/"
  description = "${var.name}"
  policy      = "${data.template_file.task_policy.rendered}"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task"
  assume_role_policy = "${file("${path.module}/assume_role.json")}"
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  role       = "${aws_iam_role.task_role.name}"
  policy_arn = "${aws_iam_policy.task_policy.arn}"
}

resource "aws_iam_role" "task_exec_role" {
  name               = "${var.name}-task-exec"
  assume_role_policy = "${file("${path.module}/assume_role.json")}"
}

resource "aws_iam_role_policy_attachment" "exec_policy_attachment" {
  role       = "${aws_iam_role.task_exec_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "container_definitions" {
  template = "${file("${path.module}/../../templates/kibana_task.tpl.json")}"

  vars {
    oauth2proxy_command = "${jsonencode(var.oauth2proxy_command)}"
    log_driver          = "${var.log_driver}"
    log_options         = "${jsonencode(var.log_options)}"
    env_prefix          = "${var.env_prefix}"
    kibana_image        = "${var.kibana_image}"

    oauth2_proxy_addr  = "${var.oauth2_proxy_addr}"
    elasticsearch_host = "${var.elasticsearch_host}"

    nginx_image = "${var.nginx_image}"
    nginx_host_port = "${var.nginx_host_port}"

    dns_servers = "${jsonencode(var.dns_servers)}"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}"
  network_mode             = "${var.network_mode}"
  requires_compatibilities = ["${var.requires_compatibilities}"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
  task_role_arn            = "${aws_iam_role.task_role.arn}"
  execution_role_arn       = "${aws_iam_role.task_exec_role.arn}"

  container_definitions = "${data.template_file.container_definitions.rendered}"
}
