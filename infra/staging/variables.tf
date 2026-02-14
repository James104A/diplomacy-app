variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "project_name" {
  type    = string
  default = "diplomacy"
}

# Networking
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Database
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "diplomacy"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

# Redis
variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

# ECS
variable "ecs_cpu" {
  type    = number
  default = 256
}

variable "ecs_memory" {
  type    = number
  default = 512
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}
