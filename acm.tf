resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
}

data "aws_acm_certificate" "cert" {
   provider = "aws"
   domain   = "${var.domain}"
   statuses = ["ISSUED"]
   most_recent = true
}

output "acm_output" {
  value = "${aws_acm_certificate.cert.arn}"
}

output "acm_output_data" {
  value = "${data.aws_acm_certificate.cert.arn}"
}

