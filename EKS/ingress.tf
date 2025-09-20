resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true

  # Keep defaults but request LoadBalancer service (so it gets an external IP / hostname)
  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
  admissionWebhooks:
    enabled: false
EOF
  ]
  depends_on = [
    data.aws_eks_cluster.cluster,
    data.aws_eks_cluster_auth.cluster
  ]
}

# Will be used to retrieve LB hostname created by helm chart
data "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.nginx_ingress.namespace
  }

  depends_on = [helm_release.nginx_ingress]
}

# Ingress resource with auth-tls annotations
resource "kubernetes_ingress_v1" "hello_ingress" {
  metadata {
    name      = "hello-ingress"
    namespace = kubernetes_namespace.hello.metadata[0].name
    annotations = {
      # enable client cert verification
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/auth-tls-secret"                      = "${kubernetes_namespace.hello.metadata[0].name}/${kubernetes_secret.ca_secret.metadata[0].name}"
      "nginx.ingress.kubernetes.io/auth-tls-verify-client"               = "on"
      "nginx.ingress.kubernetes.io/auth-tls-verify-depth"                = "1"
      "nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream" = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"                         = "true"
    }
  }

  spec {
    tls {
      hosts      = [var.host]
      secret_name = kubernetes_secret.server_tls.metadata[0].name
    }

    rule {
      host = var.host

      http {
        path {
          path = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.hello.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.hello,
    kubernetes_secret.server_tls,
    kubernetes_secret.ca_secret,
    helm_release.nginx_ingress
  ]
}
