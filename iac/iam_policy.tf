resource "aws_iam_policy" "ecr_Access_itau" {
  name = "ecr_Access_itau"
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