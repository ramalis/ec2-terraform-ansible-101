// Variable Definition
variable "myvpc_cidr" {}
variable "myvpc_tenancy" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
data "aws_availability_zones" "azone" {}
// Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = var.myvpc_cidr
  instance_tenancy     = var.myvpc_tenancy
  enable_dns_hostnames = true
  tags = {
    Name = "myvpc"
  }
}
// Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.azone.names[0]
  tags = {
    Name = "public-subnet"
  }
}
// Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.azone.names[1]
  tags = {
    Name = "private-subnet"
  }
}
// Create Internet Gateway and attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "igw-myvpc"
  }
}
// Create Elastic IP Address to assign to NAT Gateway
resource "aws_eip" "eip-natgw" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "eip-natgw"
  }
}
// Create NAT Gateway 
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip-natgw.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.igw]
  tags   = {
    Name = "natgw"
  }
}
// Create Routing Table for public subnet
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.myvpc.id
  tags   = {
    Name = "public_table"
  }
}
// Create Routing Table for private subnet
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.myvpc.id
  tags   = {
    Name = "private_table"
  }
}
// Attach Internet Gateways to public subnet
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
// Attach NAT Gateway to Private Subnet
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}
// Public subnet assiocation with Public Routing Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_table.id
}
// Private subnet assiocation with Private Routing Table 
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_table.id
}
// Create Security Group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow  SSH HTTP traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg-myvpc"
  }
}
// Outputs 
output "vpc_id" {
  value       = aws_vpc.myvpc.id
}
output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
}
output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
}
output "sg_id" {
  value       = aws_security_group.mysg.id
}