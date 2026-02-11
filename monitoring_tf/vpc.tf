resource "aws_vpc" "monitoring_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "monitoring-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.monitoring_vpc.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.monitoring_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "monitoring-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.monitoring_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
