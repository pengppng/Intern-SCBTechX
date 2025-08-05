provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_eks_cluster" "png_jenkins_eks" {
  name     = "png-jenkins-cluster"
  role_arn = aws_iam_role.png_eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.png_subnet.*.id
  }

  version = "1.31"
}

resource "aws_iam_role" "png_eks_role" {
  name = "png-eks-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

resource "aws_eks_node_group" "png_eks_nodes" {
  cluster_name    = aws_eks_cluster.png_jenkins_eks.name
  node_group_name = "png-eks-node-group"
  node_role_arn   = aws_iam_role.png_eks_node_role.arn
  subnet_ids      = aws_subnet.png_subnet.*.id
  desired_size    = 2
  max_size        = 3
  min_size        = 1
}

resource "aws_iam_role" "png_eks_node_role" {
  name = "png-eks-node-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

resource "aws_ecr_repository" "png_ecr" {
  name = "png-jenkins-ecr"
}

resource "aws_s3_bucket" "png_s3" {
  bucket = "png-jenkins-s3-bucket"
}

resource "aws_vpc" "png_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "png_subnet" {
  count = 2
  vpc_id = aws_vpc.png_vpc.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "png_sg" {
  name        = "png-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.png_vpc.id
}

resource "aws_security_group_rule" "png_sg_rule" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.png_sg.id
}

resource "aws_iam_role_policy_attachment" "png_eks_policy" {
  role       = aws_iam_role.png_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "png_node_policy" {
  role       = aws_iam_role.png_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "png_vpc_policy" {
  role       = aws_iam_role.png_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "png_ecr_policy" {
  role       = aws_iam_role.png_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "png_s3_policy" {
  role       = aws_iam_role.png_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.png_jenkins_eks.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.png_jenkins_eks.name
}

output "eks_cluster_kubeconfig" {
  value = aws_eks_cluster.png_jenkins_eks.kubeconfig[0].value
}
