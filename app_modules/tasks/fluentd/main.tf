data "template_file" "task_policy" {
  template = "${file("${path.module}/templates/policy.tpl.json")}"

  vars = {
    firehose_arns = "${jsonencode(var.firehose_arns)}"
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = "${var.name}"
  path        = "/fluentd/"
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
  template = "${file("${path.module}/templates/fluentd.tpl.json")}"

  vars {
    image   = "${var.image}"
    log_driver  = "${var.log_driver}"
    log_options = "${jsonencode(var.log_options)}"
    enviroment  = "${jsonencode(var.enviroment)}"
    dns_servers = "${jsonencode(var.dns_servers)}"
  }
}
