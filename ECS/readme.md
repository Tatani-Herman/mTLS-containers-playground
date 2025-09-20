
# How to test

## If you control the route 43 domain
```bash
terraform output -raw client_cert_pem > client.crt
terraform output -raw client_key_pem  > client.key
terraform output -raw ca_cert_pem     > ca.crt

HOST=$(terraform output -raw dns)

curl -v https://$HOST \
  --cacert ca.crt \
  --cert client.crt \
  --key client.key
```

## If you don't control the route 43 domain
Execute de test.sh script