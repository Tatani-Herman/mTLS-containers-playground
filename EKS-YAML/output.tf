output "server_cert_pem" {
  value     = tls_locally_signed_cert.server_cert.cert_pem
  sensitive = true
}

output "server_key_pem" {
  value     = tls_private_key.server_key.private_key_pem
  sensitive = true
}

output "client_cert_pem" {
  value     = tls_locally_signed_cert.client_cert.cert_pem
  sensitive = true
}

output "client_key_pem" {
  value     = tls_private_key.client_key.private_key_pem
  sensitive = true
}

output "ca_cert_pem" {
  value     = tls_self_signed_cert.ca_cert.cert_pem
  sensitive = true
}

output "dns" {
  value = var.host
}
