# EKS & ECS Hello App with ALB + mTLS

This Terraform project demonstrates deploying a simple **Hello World HTTP application** on both **AWS EKS** and **AWS ECS**, exposed via **Elastic Load Balancer (ELB)** with **mutual TLS (mTLS)** authentication. The setup includes complete infrastructure provisioning, certificate management, and service configuration.

## Flow

### ECS
```
Internet → Route53 → ALB (mTLS) → Target Group → ECS Service → Tasks
```

### EKS
```
Internet → Route53 → CLB → Target Group → EKS Service → Pods (mTLS)
```
## Directory Structure

```
.
├── EKS/
│   ├── certs.tf              # TLS certificate generation for ALB and mTLS
│   ├── eks.tf                # EKS cluster configuration
│   ├── ingress.tf            # Kubernetes Ingress and ALB configuration  
│   ├── k8s_resources.tf      # Kubernetes Deployments, Services, ConfigMaps
│   ├── kube_provider.tf      # Kubernetes provider configuration
│   ├── output.tf             # Terraform outputs (ALB hostname, cluster info)
│   ├── providers.tf          # Terraform providers (AWS, Kubernetes, Helm)
│   ├── route53.tf            # Route53 DNS configuration
│   ├── variables.tf          # Input variables and configuration
│   ├── vpc.tf                # VPC, subnets, security groups, networking
│   └── README.md             # EKS-specific deployment guide
├── ECS/
│   ├── acm.tf                # AWS Certificate Manager configuration
│   ├── alb.tf                # Application Load Balancer setup
│   ├── cert.tf               # Client/server certificate generation
│   ├── service.tf            # ECS Fargate service configuration
│   ├── task_definition.tf    # ECS task definition
│   ├── trust_store.tf        # ACM Trust Store for mTLS validation
│   ├── variables.tf          # Input variables and configuration
│   ├── vpc.tf                # VPC, subnets, security groups, networking
│   └── README.md             # ECS-specific deployment guide
└── README.md                 # This file
```

## Container Image

**Image**: `hashicorp/http-echo:0.2.3`

A lightweight test container that runs a simple HTTP server echoing back configurable text responses. 

**Key Details**:
- **Default Port**: 5678 (internal container port)
- **Purpose**: Minimal HTTP service for testing load balancers and networking

## Quick Start

### Prerequisites

- **AWS CLI** configured with appropriate IAM permissions
- **Terraform** >= 1.5
- **kubectl** (for EKS verification)
- **Docker** (optional, for local testing)

### Choose Your Platform

#### Deploy on EKS (Kubernetes)
```bash
cd EKS/
terraform init
terraform plan
terraform apply
```

#### Deploy on ECS (Fargate)
```bash
cd ECS/
terraform init
terraform plan
terraform apply
```

## Security Features

### mTLS Implementation
- **Server Certificate**: TLS certificate for ALB HTTPS termination
- **Client Certificate**: Required client certificate for mTLS authentication
- **Trust Store**: s3 Trust Store configuration for client certificate validation

## Testing

### Verify Kubernetes Resources (EKS)
```bash
kubectl get all -n ingress-nginx
kubectl logs -n ingress-nginx pod/ingress-nginx-controller
kubectl logs -n hello service/hello
```

### Verify ECS Resources
```bash
aws ecs list-services --cluster hello-mtls-ecs
aws ecs describe-services --cluster hello-mtls-ecs --services hello-service
```
