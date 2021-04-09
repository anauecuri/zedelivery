# ecs ec2 role
resource "aws_iam_role" "ecs-ec2-role" {
  name = "ecs-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs-ec2-role" {
  name = "ecs-ec2-role"
  role = "${aws_iam_role.ecs-ec2-role.name}"
}

resource "aws_iam_role_policy" "ecs-ec2-role-policy" {
  name = "ecs-ec2-role-policy"
  role = "${aws_iam_role.ecs-ec2-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ecs:CreateCluster",
              "ecs:DeregisterContainerInstance",
              "ecs:DiscoverPollEndpoint",
              "ecs:Poll",
              "ecs:RegisterContainerInstance",
              "ecs:StartTelemetrySession",
              "ecs:Submit*",
              "ecs:StartTask",
              "ecs:StopTask",
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "cloudwatch"
  role = "${aws_iam_role.ecs-ec2-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:PutParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr-policy" {
  name = "ecr-policy"
  role = "${aws_iam_role.ecs-ec2-role.id}"

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

resource "aws_iam_role_policy" "ecs-service" {
  name = "ecs-service"
  role = "${aws_iam_role.ecs-ec2-role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:Submit*",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-autoscaling" {
  name = "ecs-autoscaling"
  role = "${aws_iam_role.ecs-ec2-role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "application-autoscaling:*",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# Ecs Services Role Projects
# ECS auto scale role data
data "aws_iam_policy_document" "ecs_auto_scale_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

# ECS auto scale role
resource "aws_iam_role" "ecs_auto_scale_role" {
  name               = "itau_ecs_auto_scale_role_v1"
  assume_role_policy = data.aws_iam_policy_document.ecs_auto_scale_role.json
}

# ECS auto scale role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_auto_scale_role" {
  role       = aws_iam_role.ecs_auto_scale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role_policy" "P_AWS_AutoScaling" {
  name = "P_AWS_AutoScaling"
  role = "${aws_iam_role.ecs_auto_scale_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "*",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_AutoScaling_attach_name" {
  role = "${aws_iam_role.ecs_auto_scale_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

######
# ecs service role
resource "aws_iam_role" "ecs-service-role" {
  name = "ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-service-attach" {
  role = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "AccessToKMS" {
  count = 0
  name = "AccessToKMS"
  role = "${aws_iam_role.ecs-service-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "arn:aws:kms:sa-east-1:233801601735:key/9dd164d2-4d84-4416-af13-9226fa79c453",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:DescribeParameters"
            ],
            "Resource": "arn:aws:ssm:sa-east-1:233801601735:parameter/dev/*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AccessToKMS_attach_name" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
resource "aws_iam_role_policy" "P_AWS_DynamoDbAccessTables" {
  name = "P_AWS_DynamoDbAccessTables"
  role = "${aws_iam_role.ecs-service-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
                "arn:aws:dynamodb:*:*:table/*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_DynamoDbAccessTables_attach_name" {
  role = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
resource "aws_iam_role_policy" "P_AWS_SESSendEmail" {
  name = "P_AWS_SESSendEmail"
  role = "${aws_iam_role.ecs-service-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ses:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_SESSendEmail_attach_name" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "P_AWS_SnsPublish" {
  name = "P_AWS_SnsPublish"
  role = "${aws_iam_role.ecs-service-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:Publish",
                "sns:CreatePlatformEndpoint",
				"sns:GetEndpointAttributes",
				"sns:ListPlatformApplications",
                "sns:SetEndpointAttributes"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_SnsPublish_attach_name" {
  role = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "P_AWS_SQSAccess" {
  name = "P_AWS_SQSAccess"
  role = "${aws_iam_role.ecs-service-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_SQSAccess_attach_name" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

######
# ecs service role -  itau
resource "aws_iam_role" "ecs_service_role_itau" {
  name = "ecs_service_role_itau"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_attach_itau" {
  role = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_Attach_CwAccess_itau" {
  role = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "Access_To_KMS_itau" {
  name = "Access_To_KMS_itau"
  role = "${aws_iam_role.ecs_service_role_itau.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:DescribeParameters"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "Access_To_KMS_itau_attach_name" {
  role       = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
resource "aws_iam_role_policy" "P_AWS_DynamoDbAccess_Tables_itau" {
  name = "P_AWS_DynamoDbAccess_Tables_itau"
  role = "${aws_iam_role.ecs_service_role_itau.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
                "arn:aws:dynamodb:*:*:table/*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_DynamoDbAccess_Tables_itau_attach_name" {
  role = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
resource "aws_iam_role_policy" "P_AWS_SES_Send_Email_itau" {
  name = "P_AWS_SES_Send_Email_itau"
  role = "${aws_iam_role.ecs_service_role_itau.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ses:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_SES_Send_Email_itau_attach_name" {
  role       = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "P_AWS_Sns_Publish_itau" {
  name = "P_AWS_Sns_Publish_itau"
  role = "${aws_iam_role.ecs_service_role_itau.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_Sns_Publish_itau_attach_name" {
  role = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "P_AWS_SQS_Access_itau" {
  name = "P_AWS_SQS_Access_itau"
  role = "${aws_iam_role.ecs_service_role_itau.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "P_AWS_SQS_Access_itau_attach_name" {
  role       = "${aws_iam_role.ecs_service_role_itau.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "Task_Execution_Role_itau" {
  role       = "${aws_iam_role.ecs_service_role_itau.id}"
  policy_arn = "${aws_iam_policy.ecr_Access_itau.arn}"
}