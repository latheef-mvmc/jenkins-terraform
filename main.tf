provider "aws" {
  region = "ap-south-1"
}

variable "env" {
  description = "Environment"
  type        = string
}

resource "aws_vpc" "demo-vpc" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "demo-vpc-${var.env}"
  }
}

resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "demo-subnet-${var.env}"
  }
}
