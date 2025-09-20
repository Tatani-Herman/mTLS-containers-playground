# Deployment Guide

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl installed (optional, for verification)

## Known Issue

Due to a [known issue with the Kubernetes provider](https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775) and `kubernetes_manifest` resources, deployment must be done in stages to avoid the following error:

```
Error: Failed to construct REST client
cannot create REST client: no client config
```

This occurs because Terraform attempts to configure Kubernetes resources before the EKS cluster is fully available.

## Deployment Steps

### Step 1: Deploy Infrastructure
Deploy the VPC and EKS cluster first:

```bash
terraform init
terraform plan -target=module.vpc -target=module.eks
terraform apply -target=module.vpc -target=module.eks
```

**Wait for the EKS cluster to be fully ready** (this typically takes 10-15 minutes).

### Step 2: Deploy Kubernetes Resources
Once the EKS cluster is running, deploy the remaining resources:

```bash
terraform plan
terraform apply
```

## Verification

After successful deployment, you can verify the resources:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes
kubectl get pods,services,configmaps,secrets
```

# Test mTLS app

```bash
terraform output -raw client_cert_pem > client.crt
terraform output -raw client_key_pem  > client.key
terraform output -raw ca_cert_pem     > ca.crt

HOST=$(terraform output -raw dns)

curl -v https://$HOST \
  --cacert ca.crt \
  --cert client.crt \
  --key client.key \
  --resolve $HOST:443:$ALB_IP
```
