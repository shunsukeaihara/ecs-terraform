resource "aws_subnet" "public-subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, count.index)

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

  tags = {
    Name = "${var.env_prefix}-subnet-public${count.index + 1}"
    Made = "terraform"
  }
}

resource "aws_subnet" "private-subnets" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = var.availability_zones[count.index]
  cidr_block                      = cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(var.availability_zones) + count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, length(var.availability_zones) + count.index)
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  tags = {
    Name = "${var.env_prefix}-subnet-private${count.index + 1}"
    Made = "terraform"
  }
}
