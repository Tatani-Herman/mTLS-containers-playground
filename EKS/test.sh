#!/bin/bash
set -e  # Exit on any error

echo "=== Setting up mTLS test ==="

echo "Extracting certificates..."
terraform output -raw client_cert_pem > client.crt
terraform output -raw client_key_pem > client.key  
terraform output -raw ca_cert_pem > ca.crt

HOST=$(terraform output -raw dns)
ELB_DNS=$(terraform output -raw ingress_lb_hostname)

echo "Host: $HOST"
echo "ELB DNS: $ELB_DNS"

echo "Resolving ELB IP..."
ELB_IP=$(nslookup $ELB_DNS | grep 'Address:' | tail -1 | awk '{print $2}')

if [ -z "$ELB_IP" ]; then
    echo "Could not resolve ELB IP, trying alternative method..."
    ELB_IP=$(dig +short $ELB_DNS | head -1)
fi

echo "ELB IP: $ELB_IP"

echo "=== Test 1: Valid mTLS Certificate ==="
curl -v https://$HOST \
    --cacert ca.crt \
    --cert client.crt \
    --key client.key \
    --tlsv1.2 \
    --resolve $HOST:443:$ELB_IP

echo "=== Test 2: No Client Certificate (should get 400) ==="
curl -v https://$HOST \
    --cacert ca.crt \
    --tlsv1.2 \
    --resolve $HOST:443:$ELB_IP
