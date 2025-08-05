module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  enable_irsa = true
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::871762481972:user/admintest"
      username = "admintest"
      groups   = ["system:masters"]
    }
  ]


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}