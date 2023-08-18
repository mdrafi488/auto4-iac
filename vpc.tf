
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC

resource "aws_vpc" "vpc" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "stage-vpc"
  }
}

# Create IGW and attach to vpc

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = "stage-igw"
  }

  depends_on = [ 
    aws_vpc.vpc
   ]
}

# Create subenets

resource "aws_subnet" "public" {

  vpc_id     = aws_vpc.vpc.id

  count = length(data.aws_availability_zones.available.names)
  cidr_block = element(var.public, count.index)
  map_public_ip_on_launch = "true"

  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Stage-Public-${count.index+1}"
  }
}

resource "aws_subnet" "private" {

  vpc_id     = aws_vpc.vpc.id

  count = length(data.aws_availability_zones.available.names)
  cidr_block = element(var.private, count.index)
#   map_public_ip_on_launch = "true"

  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Stage-Private-${count.index+1}"
  }
}

resource "aws_subnet" "data" {

  vpc_id     = aws_vpc.vpc.id

  count = length(data.aws_availability_zones.available.names)
  cidr_block = element(var.data, count.index)
#   map_public_ip_on_launch = "true"

  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Stage-data-${count.index+1}"
  }
}
# Create Nat-gw in pub subnet

resource "aws_eip" "eip" {
   domain   = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Stage-NATGW"
  }

  depends_on = [aws_eip.eip]
}

# Cretae Route Tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Stg-Public Route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Stg-Private Route"
  }
}
# Associate sunbnets in route table

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data" {
  count = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.data[*].id,count.index)
  route_table_id = aws_route_table.private.id
}
