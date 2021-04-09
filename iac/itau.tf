### ECS Service ###
resource "aws_ecs_service" "itau" {
  name                               = "itau"
  cluster                            = "${aws_ecs_cluster.itau-ecs-cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.itau.arn}"
  health_check_grace_period_seconds  = "300"
  iam_role                           = "${aws_iam_role.ecs_service_role_itau.arn}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  desired_count                      = "${var.min_capacity}"
  load_balancer {
    target_group_arn = "${aws_alb_target_group.itau.id}"
    container_name   = "itau"
    container_port   = 8080
  }
}

### ALB / Target Group ###
resource "aws_alb_target_group" "itau" {
  name       = "itau"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = "${var.main_vpc}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }
  deregistration_delay = "60"
  depends_on = ["aws_alb.alb"]

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    matcher             = "200-399"
  }
  tags = {
    pep         = "00000000"
    sigla       = "itau"
    descsigla   = "itau"
    region      = "${var.region}"
    golive      = "false"
    function    = "backend"
    service     = "itau"
    owner       = "devops"
    backup      = "no"
    schedulestartstop = "no"
  }
}

### AUTO-SCALING ###
# Esse autoscaling é referente ao serviço de ECS, o arquivo autoscaling_policy.tf é referente ao EC2.
#AutoScaling
resource "aws_appautoscaling_target" "target-itau" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itau-ecs-cluster.name}/${aws_ecs_service.itau.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_auto_scale_role.arn}"
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"

}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up-itau" {
  name               = "itau-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itau-ecs-cluster.name}/${aws_ecs_service.itau.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 100
    }
  }

  //depends_on = ["${aws_appautoscaling_target.target}"]
}
# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down-itau" {
  name               = "down-itau"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.target-itau.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.target-itau.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.target-itau.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -2
    }
  }
}
### CLOUD WATCH ALARMS ###
#CPU
# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service-cpu-high-itau" {
  alarm_name          = "itau-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.itau-ecs-cluster.name}"
    ServiceName = "${aws_ecs_service.itau.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up-itau.arn}"]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service-cpu-low-itau" {
  alarm_name          = "itau-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.itau-ecs-cluster.name}"
    ServiceName = "${aws_ecs_service.itau.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.down-itau.arn}"]
}

### TASK DEFINITION ###
data "template_file" "itau" {
  template = "${file("${path.module}/json/task_definition/definitions_itau.json")}"

  vars = {
    microservice                = "itau"
    containerImage              = "983910322746.dkr.ecr.sa-east-1.amazonaws.com/itau-repo${var.ecr_registry_type}:${var.itau-image}"
    container_cpu               = "${var.container_cpu}"
    container_memory            = "${var.container_memory}"
    container_memoryReservation = "${var.container_memoryReservation}"
    container_boolean_essential = "true"
    env_container               = "${var.Env}"
    log_group                   = "${var.log_group}"
    Env                         = "${var.Env}"
    region                      = "${var.region}"
 }
}

resource "aws_ecs_task_definition" "itau" {
  family                = "itau"
  cpu                   = "${var.container_cpu}"
  memory                = "${var.container_memory}"
  task_role_arn         = "${aws_iam_role.ecs_service_role_itau.arn}"
  execution_role_arn    = "${aws_iam_role.ecs_service_role_itau.arn}"
  container_definitions = "${data.template_file.itau.rendered}"
}