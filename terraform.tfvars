#ECS
Env = "prd"
  
domain = "ze.delivery"
  
instance_type = "t2.micro"
  
KeyName =   "prd"  
  
main_vpc =   "vpc-626b821f"  
  
app_subnet_1 =   "subnet-0ab66f55"  
  
app_subnet_2 =   "subnet-db2af7bd"  
  
dmz_subnet_1 =   "subnet-7d690530"  
  
dmz_subnet_2 =   "subnet-45f92264"  
  
min_size =   "2"  
  
max_size =   "6"  
  
cidr_vpc =   "172.31.0.0/16"  
  
#ECS Service
deregistration_delay =   "0"  
  
deployment_minimum_healthy_percent =   "0"  
  
deployment_maximum_percent =   "100"    
  
min_capacity =   "1"  
  
max_capacity =   "1"  

log_group = "/ecs/zedelivery-Svc-Logs"
  
#micro service
min_capacity_service =   "2"  
  
max_capacity_service =   "6"  
  
# Services ECS
container_cpu =   "256"  
  
container_memory =   "1024"  
  
container_memoryReservation =   "1024"  
  
ecr_registry_type =   "-snapshop"  
  
#container service
container_cpu_service =   "256"  
  
container_memory_service =   "1024"  
  
container_memoryReservation_service =   "1024"   
  
#region
region = "us-east-1"  