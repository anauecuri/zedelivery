# ALB
resource "aws_security_group" "lb" {
  name        = "itau-sg-lb"
  description = "controls access to the ALB"
  vpc_id      = "${var.main_vpc}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS
resource "aws_security_group" "ecs_tasks" {
  name        = "itau-sg-ecs"
  description = "allow inbound access from the and local network ALB only"
  vpc_id      = "${var.main_vpc}"

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = ["${aws_security_group.lb.id}"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_vpc}"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Curator
resource "aws_security_group" "curator_sg" {
  name        = "itau-sg-curator-v1"
  description = "allow inbound access from the and local network"
  vpc_id      = "${var.main_vpc}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_vpc}"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ecs_tasks-id" {
  value = "${aws_security_group.ecs_tasks.id}"
}

output "lb-id" {
  value = "${aws_security_group.lb.id}"
}