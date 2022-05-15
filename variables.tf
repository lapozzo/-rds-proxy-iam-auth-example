variable "username" {
  type        = string
  description = "RDS Username"
}

variable "password" {
  type        = string
  description = "RDS Password"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "rds_enabled" {
  type = bool
  description = "RDS Enabled flag"
  default = false
}

variable "rds_proxy_enabled" {
  type = bool
  description = "RDS Proxy Enabled flag"
  default = false
}

variable "lambda_enabled" {
  type = bool
  description = "Lambda for Proxy Test Enabled flag"
  default = false
}

variable "vpc_enabled" {
  type = bool
  description = "VPC Enabled flag"
  default = false
}