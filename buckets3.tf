### Bucket S3 ###

resource "aws_s3_bucket" "ze-delivery-infra-br" {
  bucket = "s3-ze.delivery"
  acl    = "public-read"
}