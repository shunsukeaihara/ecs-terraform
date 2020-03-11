resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = var.domain_name
    Made = "terraform"
  }
}

resource "aws_route53_record" "cert" {
  count   = length(aws_acm_certificate.cert.domain_validation_options)
  zone_id = var.route53_zone_id
  name    = lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_name")
  type    = lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_type")
  ttl     = "300"
  records = lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_value")
}
