resource "aws_vpc" "vpc" {
  cidr_block                       = var.cdir_block
  assign_generated_ipv6_cidr_block = true
  instance_tenancy                 = "default"
  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"

  tags = {
    Name = "${var.env_prefix}-vpc"
    Made = "terraform"
  }
}

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env_prefix}-vpc-igw"
    Made = "terraform"
  }
}
