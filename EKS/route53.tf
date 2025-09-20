resource "aws_route53_record" "hello" {
  zone_id = var.route53_zone_id
  name    = var.host
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname]
}