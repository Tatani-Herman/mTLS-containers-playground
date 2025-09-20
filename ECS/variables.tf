variable "host" {
  type = string
  default = "hello.tbhj.com"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "hello-mtls-ecs"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "route53_zone_id" {
  type = string
  default = "Z09093563RZJQ9EYO0LL"
}