variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "hello-mtls-eks"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "host" {
  type = string
  default = "hello.tbhj.com"
}

variable "route53_zone_id" {
  type = string
  default = "Z09093563RZJQ9EYO0LL"
}
