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
  region = var.aws_region
}
variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "4.0.2"
  name           = "poc-vpc"
  cidr           = "10.0.0.0/16"
  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["10.0.10.0/24", "10.0.20.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = "poc-eks"
  cluster_version = "1.27"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  enable_cluster_creator_admin_permissions = true
  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
  }
  eks_managed_node_groups = {
    poc_nodes = {
      desired_size = 1
      min_size     = 1
      max_size     = 1
    }
  }
}
output "cluster_name" {
  value = module.eks.cluster_id
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}