terraform {
  required_providers {
    aws = {
      source : "hashicorp/aws"
      version : "4.53.0"
    }
  }
}

resource "aws_vpc" "vpc_vlan" {
  cidr_block           = "192.168.0.0/24"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "devops"
  }
}
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc_vlan.id
  cidr_block              = "192.168.0.128/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "devops"
  }
}

resource "aws_internet_gateway" "GW" {
  vpc_id = aws_vpc.vpc_vlan.id
  tags = {
    Name = "devops"
  }
}
resource "aws_route_table" "RTB" {
  vpc_id = aws_vpc.vpc_vlan.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.GW.id
  }
  tags = {
    Name = "devops"
  }
}

resource "aws_route_table_association" "routo_table_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.RTB.id
}

resource "aws_security_group" "SCG" {
  vpc_id = aws_vpc.vpc_vlan.id
  name   = "Allow all"
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }
  ingress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }
  tags = {
    Name = "devops"
  }
}

resource "aws_instance" "my_machine" {
  ami             = "ami-0557a15b87f6559cf"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_1.id
  security_groups = [aws_security_group.SCG.id]
  key_name        = "node_exporter"
}