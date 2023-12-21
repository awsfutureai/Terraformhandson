# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Public Subnets
resource "aws_subnet" "pub_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
}

# Create Private Subnets
resource "aws_subnet" "priv_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "priv_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
}

# Create Elastic IPs
resource "aws_eip" "nat_eip1" {
  instance = null # This is a placeholder, will be associated with the NAT Gateway
}

resource "aws_eip" "nat_eip2" {
  instance = null # This is a placeholder, will be associated with the second NAT Gateway
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.pub_subnet1.id
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.pub_subnet2.id
}

# Create Route Tables
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "priv_rt1" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "priv_rt2" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Public Route Table Entries
resource "aws_route" "pub_rt_entry_igw" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create Private Route Table Entries
resource "aws_route" "priv_rt1_entry_nat1" {
  route_table_id         = aws_route_table.priv_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id
}

resource "aws_route" "priv_rt2_entry_nat2" {
  route_table_id         = aws_route_table.priv_rt2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "pub_subnet1_association" {
  subnet_id      = aws_subnet.pub_subnet1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_subnet2_association" {
  subnet_id      = aws_subnet.pub_subnet2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "priv_subnet1_association" {
  subnet_id      = aws_subnet.priv_subnet1.id
  route_table_id = aws_route_table.priv_rt1.id
}

resource "aws_route_table_association" "priv_subnet2_association" {
  subnet_id      = aws_subnet.priv_subnet2.id
  route_table_id = aws_route_table.priv_rt2.id
}