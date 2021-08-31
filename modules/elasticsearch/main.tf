resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "es:*",
    ]

    resources = [
      "${aws_elasticsearch_domain.this.arn}",
      "${aws_elasticsearch_domain.this.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_elasticsearch_domain_policy" "this" {
  domain_name     = var.name
  access_policies = data.aws_iam_policy_document.this.json
  depends_on      = [aws_elasticsearch_domain.this]
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = var.name
  elasticsearch_version = var.es_version

  encrypt_at_rest = {
    enabled = var.encrypt_at_rest
  }

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = var.es_zone_awareness
  }

  log_publishing_options = []

  vpc_options {
    security_group_ids = [aws_security_group.this.id]
    subnet_ids         = [var.subnet_ids]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  tags = {
    Domain = var.name
  }

  depends_on = [aws_iam_service_linked_role.es]
}
