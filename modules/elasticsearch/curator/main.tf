resource "aws_iam_role" "this" {
  name = var.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_elasticsearch_exec" {
  name = "${var.name}-access-policy"
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "es:*"
      ],
      "Resource": ["${var.elasticsearch_arn}", "${var.elasticsearch_arn}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_exec" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "this" {
  name        = var.name
  description = var.name
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "this" {
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = base64sha256(file("${path.module}/lambda_function.zip"))
  role             = "aws_iam_role.this.arn
  handler          = "logrotate.lambda_handler"
  function_name    = var.name
  runtime          = "python3.6"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  vpc_config {
    subnet_ids         = [var.subnet_ids]
    security_group_ids = [aws_security_group.this.id]
  }

  environment {
    variables = {
      ES_HOST         = var.elasticsearch_endpoint
      ES_INDEX_PREFIX = "cwl"
      ROTATION_PERIOD = var.rotation_period
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = var.name
  schedule_expression = "cron(0 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.name}-targe
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "curator" {
  statement_id  = "${var.name}-cloudwatch-event-allow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
