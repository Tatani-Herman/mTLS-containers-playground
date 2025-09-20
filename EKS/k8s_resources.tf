resource "kubernetes_namespace" "hello" {
  metadata {
    name = "hello"
  }

  depends_on = [
    module.eks.eks_managed_node_groups
  ]
}

# Create secret with server TLS (server cert + key) in the namespace ingress-nginx expects
resource "kubernetes_secret" "server_tls" {
  metadata {
    name      = "hello-server-tls"
    namespace = kubernetes_namespace.hello.metadata[0].name
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.server_cert.cert_pem
    "tls.key" = tls_private_key.server_key.private_key_pem
  }

  type = "kubernetes.io/tls"
}

# Create secret containing the CA (to be used as auth-tls-secret by nginx)
resource "kubernetes_secret" "ca_secret" {
  metadata {
    name      = "hello-ca"
    namespace = kubernetes_namespace.hello.metadata[0].name
  }
  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
  }
  type = "Opaque"
}

# Deploy a tiny http-echo pod (simple hello)
resource "kubernetes_deployment" "hello" {
  metadata {
    name      = "hello"
    namespace = kubernetes_namespace.hello.metadata[0].name
    labels = {
      app = "hello"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "hello"
      }
    }
    template {
      metadata {
        labels = {
          app = "hello"
        }
      }
      spec {
        container {
          name  = "http-echo"
          image = "hashicorp/http-echo:0.2.3"
          args  = ["-text", "Hello World!"]
          port {
            container_port = 5678
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello" {
  metadata {
    name      = "hello"
    namespace = kubernetes_namespace.hello.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.hello.metadata[0].labels["app"]
    }
    port {
      port        = 80
      target_port = 5678
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}
