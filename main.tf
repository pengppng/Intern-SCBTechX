terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable "repository_name" {
  default = "preecr"
}

variable "lifecycle_policy" {
  default = "lifecycle-policy.json"
}

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

# ------------------------------------
# ✅ เพิ่ม VPC สำหรับ EKS
# ------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}

# ------------------------------------
# ✅ เพิ่ม EKS Cluster
# ------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = "preecr-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
  }

  eks_managed_node_groups = {
    preecr = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


output "ecr_repo_url" {
  value = aws_ecr_repository.preecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
