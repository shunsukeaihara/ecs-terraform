resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)
  vpc   = true

  tags = {
    Name = "${var.env_prefix}-eip-nat${count.index + 1}"
    Made = "terraform"
  }
}

resource "aws_nat_gateway" "gw" {
  count         = var.single_nat_gateway ? 1 : length(var.availability_zones)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, (var.single_nat_gateway ? 0 : count.index))

  tags = {
    Name = "${var.env_prefix}-nat${count.index + 1}"
    Made = "terraform"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, (var.single_nat_gateway ? 0 : count.index))
  }

  tags = {
    Name = "${var.env_prefix}-private-${var.availability_zones[count.index]}-rtb"
    Made = "terraform"
  }
}

resource "aws_route_table_association" "private-association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "private-s3-association" {
  count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-public-rtb"
    Made = "terraform"
  }
}

resource "aws_route_table_association" "public-association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
