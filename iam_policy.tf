resource "aws_iam_policy" "ecr_Access_zedelivery" {
  name = "ecr_Access_zedelivery"
  path = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ] 
}
EOF 
}