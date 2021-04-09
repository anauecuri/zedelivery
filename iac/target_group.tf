# Default
resource "aws_alb_target_group" "default-target-group" {
  name       = "default-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = "${var.main_vpc}"
  depends_on = ["aws_alb.alb"]

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200"
  }
  tags = {
    pep         = "00000000"
    sigla       = "itau"
    descsigla   = "itau"
    region      = "${var.region}"
    golive      = "false"
    function    = "backend"
    service     = "web"
    owner       = "devops"
  }
}