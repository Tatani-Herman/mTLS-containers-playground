resource "kubernetes_manifest" "namespace" {
  manifest = yamldecode(file("${path.module}/templates/namespace.yaml"))
  depends_on = [
    module.eks
  ]
}

resource "kubernetes_manifest" "configmap" {
  manifest = yamldecode(file("${path.module}/templates/configmap.yaml"))
  depends_on = [
    module.eks,
    kubernetes_manifest.namespace
  ]
}

resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(file("${path.module}/templates/deployment.yaml"))
  depends_on = [
    module.eks,
    kubernetes_manifest.namespace
  ]
}

resource "kubernetes_manifest" "service" {
  manifest = yamldecode(file("${path.module}/templates/service.yaml"))
  depends_on = [
    module.eks,
    kubernetes_manifest.namespace
  ]
}

# ISSUE: kubernetes_manifest with templatefile() and dynamic values
# 
# Error: "API did not recognize GroupVersionKind from manifest (CRD may not be installed)"
# Additional error: "unmarshaling unknown values is not supported"
#
# ROOT CAUSE: 
# The kubernetes_manifest resource cannot properly parse YAML templates that contain
# Terraform expressions/interpolations. When using templatefile() with dynamic values
# (like certificate data from tls_* resources), the YAML parser fails during the
# unmarshaling process before the Kubernetes API validation even occurs.

# resource "kubernetes_manifest" "hello_tls_secret" {
#   manifest = yamldecode(templatefile("${path.module}/templates/secret.yaml", {
#     tls_crt = base64encode(tls_locally_signed_cert.server_cert.cert_pem)
#     tls_key = base64encode(tls_private_key.server_key.private_key_pem)
#     ca_crt  = base64encode(tls_self_signed_cert.ca_cert.cert_pem)
#   }))
  
#   depends_on = [
#     module.eks,
#     kubernetes_manifest.namespace
#   ]
# }

resource "kubernetes_secret" "hello_tls_secret" {
  metadata {
    name      = "hello-tls"
    namespace = "hello"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.server_cert.cert_pem
    "tls.key" = tls_private_key.server_key.private_key_pem
    "ca.crt"  = tls_self_signed_cert.ca_cert.cert_pem
  }

  depends_on = [
    module.eks,
    kubernetes_manifest.namespace
  ]
}
