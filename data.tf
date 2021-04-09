# Get the latest ECS AMI
data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data for ECS cluster
data "template_file" "ecs-cluster" {
  template = "${file("${path.module}/ecs-cluster.tpl")}"

  vars = {
    ecs_cluster = "${aws_ecs_cluster.itau-ecs-cluster.name}"
  }
}
