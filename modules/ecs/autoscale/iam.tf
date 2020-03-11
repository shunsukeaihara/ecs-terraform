resource "aws_iam_role" "autoscale_role" {
  name               = "${var.name}-autoscale-role"
  assume_role_policy = file("policies/autoscale-assume-role.json")
}

resource "aws_iam_policy_attachment" "autoscale_role_attach" {
  name       = "${var.name}-autoscale-role-attach"
  roles      = [aws_iam_role.autoscale_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name}-instance-role"
  assume_role_policy = file("policies/ec2-assume-role.json")
}

resource "aws_iam_policy_attachment" "instance_role_attach" {
  name       = "${var.name}-instance-role-attach"
  roles      = [aws_iam_role.instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  path = "/"
  role = aws_iam_role.instance_role.name
}
