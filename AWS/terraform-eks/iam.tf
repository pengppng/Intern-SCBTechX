resource "aws_iam_role" "jenkins_eks_role" {
  name = "JenkinsEKSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# AWS Managed Policies

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_full" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_full" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc_full" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# Custom Inline Policy

resource "aws_iam_role_policy" "custom_eks_policy" {
  name = "JenkinsEKSCustomPolicy"
  role = aws_iam_role.jenkins_eks_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          "ForAnyValue:StringLike" = {
            "aws:TagKeys" = "kubernetes.io/cluster/*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTopology",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
