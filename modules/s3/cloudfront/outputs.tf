output "arn" {
  value = aws_s3_bucket.this.arn
}

output "name" {
  value = aws_s3_bucket.this.id
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
