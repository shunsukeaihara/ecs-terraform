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
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${var.src_bucket_arn}",
        "${var.src_bucket_arn}/*",
        "${var.dest_bucket_arn}",
        "${var.dest_bucket_arn}/*"
      ]
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

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "upload/${var.name}-lambda.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  function_name    = var.name
  runtime          = "nodejs8.10"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  vpc_config {
    subnet_ids         = [var.subnet_ids]
    security_group_ids = [aws_security_group.this.id]
  }

  environment {
    variables = {
      ES_ENDPOINT = var.elasticsearch_endpoint
      DEST_BUCKET = var.dest_bucket_name
    }
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${var.name}-s3-event-allow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.src_bucket_arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = var.src_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "succeeded"
    filter_suffix       = ".gz"
  }
}
