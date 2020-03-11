resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${aws_s3_bucket.this.id}-origin-access-identity"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = var.domain
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  retain_on_delete    = true
  aliases             = [var.domain]

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.this.id
    origin_path = ""

    /*
                        custom_origin_config {
                          http_port              = "80"
                          https_port             = "443"
                          origin_protocol_policy = "http-only"
                          origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
                        }
                        */
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this.id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  tags {}
}
