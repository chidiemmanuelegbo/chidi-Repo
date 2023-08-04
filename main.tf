#Networking for Grace IT

resource "aws_vpc" "Grace-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Grace-vpc"
  }
}
# Prod-Pub-Sub1

resource "aws_subnet" "Prod-Pub-Sub1" {
  vpc_id     = aws_vpc.Grace-vpc.id
  cidr_block = "10.0.120.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-Pub-Sub1"
  }
}

# Prod-Pub-Sub2

resource "aws_subnet" "Prod-Pub-Sub2" {
  vpc_id     = aws_vpc.Grace-vpc.id
  cidr_block = "10.0.132.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-Pub-Sub2"
  }
}

# Prod-Priv-Sub1

resource "aws_subnet" "Prod-Priv-Sub1" {
  vpc_id     = aws_vpc.Grace-vpc.id
  cidr_block = "10.0.147.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "Prod-Priv-Sub1"
  }
}

# Prod-Priv-Sub2

resource "aws_subnet" "Prod-Priv-Sub2" {
  vpc_id     = aws_vpc.Grace-vpc.id
  cidr_block = "10.0.162.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-Priv-Sub2"
  }
}

# Prod-Pub-route-table

resource "aws_route_table" "Prod-Pub-RT" {
  vpc_id = aws_vpc.Grace-vpc.id

  tags = {
    Name = "Prod-Pub-RT"
  }
}

# associate production public subnet 1&2 to public route table

resource "aws_route_table_association" "Prod-pub-RT-assoc-to-prod-pub-sub1" {
  subnet_id      = aws_subnet.Prod-Pub-Sub1.id
  route_table_id = aws_route_table.Prod-Pub-RT.id
 }

resource "aws_route_table_association" "Prod-pub-RT-assoc-to-prod-pub-sub2" {
  subnet_id      = aws_subnet.Prod-Pub-Sub2.id
  route_table_id = aws_route_table.Prod-Pub-RT.id
 }


# Prod-Priv-route-table

resource "aws_route_table" "Prod-Priv-RT" {
  vpc_id = aws_vpc.Grace-vpc.id

  tags = {
    Name = "Prod-Priv-RT"
  }
}

# associate production private subnets 1&2 to private route table

resource "aws_route_table_association" "Prod-pub-RT-assoc-to-prod-priv-sub1" {
  subnet_id      = aws_subnet.Prod-Priv-Sub1.id
  route_table_id = aws_route_table.Prod-Priv-RT.id
 }

resource "aws_route_table_association" "Prod-pub-RT-assoc-to-prod-priv-sub2" {
  subnet_id      = aws_subnet.Prod-Priv-Sub2.id
  route_table_id = aws_route_table.Prod-Priv-RT.id
 }


# Prod IGW

resource "aws_internet_gateway" "Prod-IGW" {
  vpc_id = aws_vpc.Grace-vpc.id


  tags = {
    Name = "Prod-IGW"
  }
}


# Associate the internet gateway with the public route table

resource "aws_route" "Prod-IGW-assoc-Prod-Pub-RT" {
  gateway_id     = aws_internet_gateway.Prod-IGW.id
  route_table_id = aws_route_table.Prod-Pub-RT.id
  destination_cidr_block = "0.0.0.0/0"

}

# Create  Elastic IP Address
resource "aws_eip" "Prod-elastic-ip" {
  tags = {
    Name = "Prod-elastic-ip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.Prod-elastic-ip.id
  subnet_id     = aws_subnet.Prod-Pub-Sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }

}

# NAT Associate with Priv route

resource "aws_route" "Prod-Nat-gateway-assoc-Prod-Priv-RT" {
  route_table_id = aws_route_table.Prod-Priv-RT.id
  gateway_id = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}