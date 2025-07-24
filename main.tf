provider "aws" {
  region = "ap-southeast-1"
}

# == Variables ==

variable "repository_name" {
  default = "preecr"
}

variable "lifecycle_policy" {
  default = "lifecycle-policy.json"
}

variable "cluster_name" {
  default = "preecr-cluster"
}

# == ECR Repository ==

resource "aws_ecr_repository" "preecr" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name        = var.repository_name
    Environment = "dev"
  }
}

resource "aws_ecr_lifecycle_policy" "preecr_policy" {
  repository = aws_ecr_repository.preecr.name
  policy     = file(var.lifecycle_policy)
}

# == VPC for EKS ==

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# == EKS Cluster ==

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      max_size     = 1
      min_size     = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# == Outputs ==
output "ecr_repo_url" {
  value = aws_ecr_repository.preecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
