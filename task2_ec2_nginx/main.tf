provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["assessment-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

resource "aws_security_group" "nginx" {
  name   = "nginx-sg"
  vpc_id = data.aws_vpc.selected.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami           = "ami-0c2af51e6b2f6f0d0"  # Amazon Linux 2 in ap-south-1
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.public.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.nginx.id]
  user_data     = file("nginx_user_data.sh")
  tags = { Name = "nginx-ec2-task2" }
}

output "nginx_public_ip" { value = aws_instance.nginx.public_ip }
