resource "aws_iam_role" "transformer" {
  name = "${var.name}-transformer"

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

resource "aws_iam_role_policy_attachment" "transformer_lambda_exec" {
  role       = aws_iam_role.transformer.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "transformer_kinesis" {
  role       = aws_iam_role.transformer.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

data "archive_file" "transformer" {
  type        = "zip"
  source_dir  = "${path.module}/${var.es_format ? "es_format" : "raw_message"}"
  output_path = "upload/${var.name}-lambda.zip"
}

resource "aws_lambda_function" "transformer" {
  filename         = data.archive_file.transformer.output_path
  source_code_hash = data.archive_file.transformer.output_base64sha256
  role             = aws_iam_role.transformer.arn
  handler          = "index.handler"
  function_name    = "${var.name}-transformer"
  runtime          = "nodejs8.10"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout
}
