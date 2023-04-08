# Create the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

# Create two subnets
resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my_private_subnet"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my_public_subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_public_route_table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "my_public_subnet_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

# Create a route table for the private subnet
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "my_private_route_table"
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id             = aws_subnet.my_public_subnet.id
  allocation_id         = aws_eip.my_nat_eip.id
  tag_specifications {
    resource_type = "natgateway"
    tags = {
      Name = "my_nat_gateway"
    }
  }
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "my_private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}

# Create an Elastic IP
resource "aws_eip" "my_nat_eip" {
  vpc = true
  tags = {
    Name = "my_nat_eip"
  }
}

# Create a Virtual Machine
resource "aws_instance" "my_vm" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_private_subnet.id
  tags = {
    Name = "my_vm"
  }
}

# Test internet access
resource "null_resource" "test_internet_access" {
  provisioner "local-exec" {
    command = "curl -s http://checkip.amazonaws.com > /tmp/checkip.txt"
  }
}

# Check Public IP
resource "null_resource" "check_public_ip" {
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ubuntu@${aws_instance.my_vm.public_ip} 'curl -s http://checkip.amazonaws.com > /tmp/checkip.txt'"
  }
}
