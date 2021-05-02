## s3 policy e Bucket ##
data "aws_iam_policy_document" "s3_policy_partner-frontend" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_partner-frontend.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity_partner-frontend.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.site_partner-frontend.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity_partner-frontend.iam_arn}"]
    }
  }

  statement {
    sid = "ForceSSLOnlyAccess"
    effect = "Deny"
    actions = ["s3:*"] 
    resources = ["${aws_s3_bucket.site_partner-frontend.arn}"]
    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"] 
    }
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity_partner-frontend.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy_partner-frontend" {
  bucket = "${aws_s3_bucket.site_partner-frontend.id}"
  policy = "${data.aws_iam_policy_document.s3_policy_partner-frontend.json}"
}
resource "aws_s3_bucket" "site_partner-frontend" {
  bucket = "zedelivery-partner-frontend"
  acl    = "private"
  server_side_encryption_configuration {
  rule {
  apply_server_side_encryption_by_default {
  sse_algorithm ="AES256"
       }
     }
   }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "log_partner-frontend" {
  bucket = "zedelivery-partner-frontend-logs"
  acl    = "log-delivery-write"
  server_side_encryption_configuration {
  rule {
  apply_server_side_encryption_by_default {
  sse_algorithm ="AES256"
       }
     }
   }
  lifecycle_rule {
      id      = "seven_days_retention"
      prefix  = "cdn/"
      enabled = true

      expiration {
          days = 7
      }
   }
}

## Cloudfront ##

resource "aws_cloudfront_origin_access_identity" "origin_access_identity_partner-frontend" {
  comment = "cloudfront origin access identity"
}
resource "aws_cloudfront_distribution" "website_cdn_partner-frontend" {
  enabled      = true
  price_class  = (var.Env == "prd" ? "PriceClass_All" : "PriceClass_100")
  http_version = "http1.1"
  aliases      = ["partner-frontend.${var.domain}"]
  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.site_partner-frontend.id}"
    domain_name = "zedelivery-partner-frontend.s3.${var.region}.amazonaws.com"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity_partner-frontend.cloudfront_access_identity_path}"
    }
  }
  default_root_object = "index.html"
  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.log_partner-frontend.bucket_domain_name}"
    prefix          = "cdn"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.site_partner-frontend.id}"
    min_ttl          = "0"
    default_ttl      = "3600"  //3600
    max_ttl          = "86400" //86400
    viewer_protocol_policy = "allow-all"
    compress               = true
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.cert.arn}"
    ssl_support_method  = "sni-only"
    cloudfront_default_certificate = true
    minimum_protocol_version = "TLSv1.2_2019"
  }
}

output "cdn_output_partner-frontend" {
  value = "${aws_cloudfront_distribution.website_cdn_partner-frontend.domain_name}"
}
output "cdn_id_partner-frontend" {
  value = "${aws_cloudfront_distribution.website_cdn_partner-frontend.id}"
}

# Upload S3 Application --- considerando que a imagem da aplicacao front esta no nexus
resource "null_resource" "site_files_partner-frontend" {
 triggers = {
   build_number = "${timestamp()}"
 }
  provisioner "local-exec" {
   command = "wget -O partner-frontend.zip --no-check-certificate https://nexus-release-corp.ccorp.local/repository/zedelivery/partner-frontend.zip"
 }
 provisioner "local-exec" {
   command = "unzip partner-frontend.zip -d partner-frontend/"
 }
 provisioner "local-exec" {
   command = "aws s3 sync partner-frontend/build/ s3://zedelivery-partner-frontend/"
 }
 provisioner "local-exec" {
   command = "aws configure set preview.cloudfront true"
 }
 provisioner "local-exec" {
   command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website_cdn_partner-frontend.id} --paths '/*'"
 }
}

# Route 53 ##
resource "aws_route53_zone" "primary-part" {
  name = "partner-frontend.${var.domain}"
}

resource "aws_route53_record" "zedelivery-partner-frontend" {
  zone_id = "${aws_route53_zone.primary-part.zone_id}"
  name    = "partner-frontend.${var.domain}"
  type    = "CNAME"
  ttl     = "5"
  records = ["${aws_cloudfront_distribution.website_cdn_partner-frontend.domain_name}"]
}