#Memory
resource "aws_cloudwatch_metric_alarm" "CloudWatchMemoryAlarm" {
  alarm_name          = "zedelivery-Infra-ECS-Memory-Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.zedelivery-ecs-cluster.name}"
  }
}
#Cpu
resource "aws_cloudwatch_metric_alarm" "CloudWatchCpuAlarm" {
  alarm_name          = "zedelivery-Infra-ECS-CPU-Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.zedelivery-ecs-cluster.name}"
  }
}