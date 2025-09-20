resource "aws_security_group" "alb_sg" {
  name        = "hello-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "hello" {
  name               = "hello-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "hello" {
  name        = "hello-tg"
  port        = 5678
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.hello.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.server_cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  mutual_authentication {
    mode            = "verify"
    trust_store_arn = aws_lb_trust_store.client_ca.arn
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello.arn
  }
}


resource "aws_route53_record" "hello" {
  zone_id = var.route53_zone_id
  name    = var.host
  type    = "A"

  alias {
    name                   = aws_lb.hello.dns_name
    zone_id                = aws_lb.hello.zone_id
    evaluate_target_health = true
  }
}
