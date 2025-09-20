module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  addons = {
    vpc-cni = {
      most_recent = true
      before_compute = true  # Install before node groups
    }
    coredns = {}
    kube-proxy = {}
  }

  name               = var.cluster_name
  kubernetes_version = "1.33"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  endpoint_public_access      = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    ng = {
      desired_size    = 1
      min_size        = 1 
      max_size        = 2
      instance_types  = ["t3.medium"]
      subnet_ids      = module.vpc.private_subnets
      ami_type = "AL2023_x86_64_STANDARD"
    }
  }
}
