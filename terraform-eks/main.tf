terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.2"

  cluster_name    = "preecr-cluster"
  cluster_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access  = true

  enable_irsa        = true

  create_kms_key              = false
  cluster_encryption_config   = []

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
  }

  eks_managed_node_groups = {
    default = {
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



output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
