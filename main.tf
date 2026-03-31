provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "demo-vpc-${var.env}"
    Environment = var.env
  }
}

resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name        = "demo-subnet-${var.env}"
    Environment = var.env
  }
}
