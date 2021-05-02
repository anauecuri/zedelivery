#ECS
variable "Env" {}
variable "domain" {}
variable "instance_type" {}
variable "KeyName" {}
variable "main_vpc" {}
variable "app_subnet_1" {}
variable "app_subnet_2" {}
variable "dmz_subnet_1" {}
variable "dmz_subnet_2" {}
variable "min_size" {}
variable "max_size" {}
variable "cidr_vpc" {}
variable "log_group" {}
#ECS Service
variable "deregistration_delay" {}
variable "deployment_minimum_healthy_percent" {}
variable "deployment_maximum_percent" {}
variable "min_capacity" {}
variable "max_capacity" {}
#service
variable "min_capacity_service" {}
variable "max_capacity_service" {}
# container service
variable "container_cpu" {}
variable "container_memory" {}
variable "container_memoryReservation" {}
variable "ecr_registry_type" {}
#service
variable "container_cpu_service" {}
variable "container_memory_service" {}
variable "container_memoryReservation_service" {}

#region
variable "region" {}

#docker image
variable "zedelivery-backend-image" {
  default = "1.0"
}
variable "zedelivery-consumerapp-image" {
  default = "1.0"
}
variable "zedelivery-consumerweb-image" {
  default = "1.0"
}
variable "zedelivery-entregadorapp-image" {
  default = "1.0"
}
variable "zedelivery-partnerwebapp-image" {
  default = "1.0"
}