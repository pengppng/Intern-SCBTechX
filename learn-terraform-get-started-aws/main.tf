terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "cloudmigrate"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "learn-terraform"
  }
}
