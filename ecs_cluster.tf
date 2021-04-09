resource "aws_ecr_repository" "itau-repo" {
  name                 = "itau-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "itau-ecs-cluster" {
  name = "itau-ecs-cluster"
}

resource "aws_autoscaling_group" "itau-ecs-cluster" {
  name                      = "itau-ecs-cluster"
  vpc_zone_identifier       = ["${var.app_subnet_1}", "${var.app_subnet_2}"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  launch_configuration      = "${aws_launch_configuration.itau-ecs-lc.name}"
  health_check_type         = "EC2"
  force_delete              = true
  health_check_grace_period = 300
  default_cooldown          = 300
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]

  tag {
    key    = "Name"
    value  = "itau-ecs-cluster"
    propagate_at_launch = true
  }
  tag {  
    key    = "pep"         
    value  = "itau"
    propagate_at_launch = true
  }
  tag { 
    key    = "sigla"       
    value  = "itau"
    propagate_at_launch = true
  }
  tag { 
    key    = "descsigla"   
    value  = "itau"
    propagate_at_launch = true
  }
  tag { 
    key    = "project"     
    value  = "itau"
    propagate_at_launch = true
  }
  tag { 
    key    = "region"      
    value  = "${var.region}"
    propagate_at_launch = true
  }
  tag { 
    key    = "golive"      
    value  = "false"
    propagate_at_launch = true
  }
  tag { 
    key    = "function"    
    value  = "backend"
    propagate_at_launch = true
  }
  tag { 
    key    = "service"     
    value  = "web"
    propagate_at_launch = true
  }
  tag { 
    key    = "owner"      
    value  = "devops"
    propagate_at_launch = true
  }
}
resource "aws_launch_configuration" "itau-ecs-lc" {
  name_prefix                 = "itau-ecs-lc"
  security_groups             = ["${aws_security_group.ecs_tasks.id}"]
  key_name                    = "${var.KeyName}"
  image_id                    = "${data.aws_ami.latest_ecs.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-ec2-role.id}"
  user_data                   = "${data.template_file.ecs-cluster.rendered}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}
output "ecs_output" {
  value = "${aws_ecs_cluster.itau-ecs-cluster.name}"
}
