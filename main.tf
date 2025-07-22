provider "aws" {
  region = var.region
}
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "ecr_repo_name" {
  description = "ECR Repository Name"
  type        = string
  default     = "preecr"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "preecr-cluster"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "preecr-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_ecr_repository" "preecr" {
  name = var.ecr_repo_name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      desired_size   = 1
      min_size       = 1
      max_size       = 1
    }
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.private_subnets
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.preecr.repository_url
}
