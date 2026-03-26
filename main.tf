provider "aws" {
    profile = "default"
    region  = "ap-south-1"
  
}
resource "aws_vpc" "demo-vpc" {
    cidr_block = "90.0.0.0/16"
    tags = {
        Name = "demo-vpc"
    }
  
}


