provider "aws" {
    profile = "default"
    region  = "ap-south-1"
  
}
resource "aws_vpc" "demo-vpc" {
    cidr_block = "90.0.0.0/16"
    tags = {
        Name = "jenkins-terraform-vpc1"
    }
  
}

resource "aws_subnet" "demo-subnet" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "90.0.3.0/24"
    tags = {
        Name = "public-subnet1"
    }
}
