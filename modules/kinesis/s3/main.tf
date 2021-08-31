resource "aws_iam_role" "this" {
  name = "${var.name}-kinesis"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.name

  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${var.dist_bucket_arn}", "${var.dist_bucket_arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:*:*:log-group:*:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": ["${aws_lambda_function.transformer.arn}:$LATEST", "${aws_lambda_function.transformer.arn}:$LATEST/*"]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.name}-kinesis"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = "kinesis"
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.this.arn
    bucket_arn          = var.dist_bucket_arn
    buffer_size         = var.buffer_size
    buffer_interval     = var.buffer_interval
    prefix              = "succeeded/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "failed/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}"
    compression_format  = "GZIP"

    processing_configuration = [
      {
        enabled = "true"

        processors = [
          {
            type = "Lambda"

            parameters = [
              {
                parameter_name  = "LambdaArn"
                parameter_value = "${aws_lambda_function.transformer.arn}:$LATEST"
              },
              {
                parameter_name  = "BufferIntervalInSeconds"
                parameter_value = var.buffer_interval_in_seconds
              },
              {
                parameter_name  = "BufferSizeInMBs"
                parameter_value = var.buffer_size_in_mbs
              },
              {
                parameter_name  = "NumberOfRetries"
                parameter_value = var.number_of_retries
              },
            ]
          },
        ]
      },
    ]

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.this.name
      log_stream_name = aws_cloudwatch_log_stream.this.name
    }
  }

  depends_on = ["aws_iam_role_policy.this"]
}

resource "aws_iam_role" "subscription" {
  name = "${var.name}-subscription-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.ap-northeast-1.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "to_kinesis" {
  role = aws_iam_role.subscription.name

  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["firehose:*"],
      "Resource": [aws_kinesis_firehose_delivery_stream.this.arn]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  name            = "${var.name}-subscription"
  role_arn        = aws_iam_role.subscription.arn
  log_group_name  = var.log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = aws_kinesis_firehose_delivery_stream.this.arn
  depends_on      = [aws_iam_role_policy.to_kinesis]
}
