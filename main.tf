provider "aws" {
  region = "ap-southeast-1" # change if needed
}

resource "aws_ecr_repository" "preecr" {
  name = "preecr"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "preecr"
  }
}
