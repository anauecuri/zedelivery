#CPU Policy UP
resource "aws_autoscaling_policy" "autopolicy_cpu" {
  name                   = "itau-autopolicy-up-cpu"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.itau-ecs-cluster.name}"
}
#Cpu Alarm UP
resource "aws_cloudwatch_metric_alarm" "cpualarm" {
  alarm_name          = "high-ecs-utilization-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = (var.Env == "prd" ? "70" : "75")

  dimensions = {
    ClusterName = "${aws_ecs_cluster.itau-ecs-cluster.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  actions_enabled = true
  alarm_actions     = ["${aws_autoscaling_policy.autopolicy_cpu.arn}"]
}
#CPU Policy Down
resource "aws_autoscaling_policy" "autopolicy-down-cpu" {
  name                   = "itau-autopolicy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.itau-ecs-cluster.name}"
}
#CPU Alarm Down
resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name          = "low-ecs-utilization-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.itau-ecs-cluster.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  actions_enabled = true
  alarm_actions     = ["${aws_autoscaling_policy.autopolicy-down-cpu.arn}"]
}