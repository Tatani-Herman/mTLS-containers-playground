resource "aws_s3_bucket" "mtls" {
  bucket = "tbhj-mtls-bundle"
}

resource "aws_s3_bucket_policy" "allow_alb" {
  bucket = aws_s3_bucket.mtls.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${aws_s3_bucket.mtls.arn}",
          "${aws_s3_bucket.mtls.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_object" "ca_bundle" {
  bucket = aws_s3_bucket.mtls.id
  key    = "ca.pem"
  content = tls_self_signed_cert.ca_cert.cert_pem
}

resource "aws_lb_trust_store" "client_ca" {
  ca_certificates_bundle_s3_bucket = aws_s3_bucket.mtls.bucket
  ca_certificates_bundle_s3_key    = aws_s3_object.ca_bundle.key
  name                             = "hello-truststore"
}
