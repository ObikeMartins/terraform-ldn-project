# create a vpc 
resource "aws_vpc" "anita-vpc" {
  cidr_block           = "25.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "anita-vpc"
  }

}

#2 Ceate internet gateway
resource "aws_internet_gateway" "anita-igw" {
  vpc_id = aws_vpc.anita-vpc.id

  tags = {
    Name         = "anita-igw"
    envvironment = "devops"
  }
}

#3 Create a public Route Table

resource "aws_route_table" "anita-pubrt" {
  vpc_id = aws_vpc.anita-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.anita-igw.id
  }

  #   route {
  #     ipv6_cidr_block        = "::/0"
  #     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  #   }

  tags = {
    Name         = "anita-pubrt"
    envvironment = "devops"
  }
}

#4 create a Public subnet in eu-west-2a

resource "aws_subnet" "anita-pubsn-2a" {
  vpc_id            = aws_vpc.anita-vpc.id
  availability_zone = "eu-west-2a"
  cidr_block        = "25.0.0.0/24"

  tags = {
    Name         = "anita-pubsn-2a"
    envvironment = "devops"
  }
}

#5 Associate the subnet with the RT

resource "aws_route_table_association" "anita-pubsn-2a" {
  subnet_id      = aws_subnet.anita-pubsn-2a.id
  route_table_id = aws_route_table.anita-pubrt.id
}

#6 Create a security group

resource "aws_security_group" "anita-pubsg" {
  vpc_id      = aws_vpc.anita-vpc.id
  name        = "anita-pubsg"
  description = "Access to SSH and RDP from a single IP address & HTTPS from anywhere"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["198.165.212.45/32"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["198.165.212.45/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "anita-pubsg"
    envvironment = "devops"
  }

}

#7 Create a network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "anita-nic" {
  subnet_id       = aws_subnet.anita-pubsn-2a.id
  private_ips     = ["25.0.0.4"]
  security_groups = [aws_security_group.anita-pubsg.id]
}

#8 Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "anita-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.anita-nic.id
  associate_with_private_ip = "25.0.0.4"


  depends_on = [aws_internet_gateway.anita-igw]

    tags = {
        Name         = "anita-eip"
        envvironment = "devops"
    }

}

#9 Launch an EC2 instance.

resource "aws_instance" "sam-server1" {
  ami           = "ami-01ec84b284795cbc7" # us-west-2 Ubuntu Server 24.04
  instance_type = "t2.micro"
  key_name      = "mez-london-key"

  network_interface {
    network_interface_id = aws_network_interface.anita-nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name         = "sam-server1"
    envvironment = "devops"
  }
}








