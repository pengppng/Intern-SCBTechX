terraform {
  backend "s3" {
    bucket         = "png-terraform-state-bucket"
    key            = "ecr/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable "repository_name" {
  default     = "preecr"
  type        = string
}

variable "lifecycle_policy" {
  default     = "lifecycle-policy.json"
  type        = string
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
