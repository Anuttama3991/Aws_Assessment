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
    tags = {
      Name = "public*"
    }
  }
}

resource "aws_security_group" "alb" {
  name   = "alb-sg-task3"
  vpc_id = data.aws_vpc.selected.id
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

resource "aws_security_group" "asg" {
  name   = "asg-sg-task3"
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_launch_configuration" "nginx" {
  name_prefix     = "nginx-task3-"
  image_id        = "ami-0c2af51e6b2f6f0d0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg.id]
  user_data       = file("nginx_user_data_asg.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx" {
  name                = "nginx-asg-task3"
  launch_configuration = aws_launch_configuration.nginx.name
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = data.aws_subnets.public.ids
  target_group_arns   = [aws_lb_target_group.nginx.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "nginx-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "nginx" {
  name               = "nginx-alb-task3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_target_group" "nginx" {
  name     = "nginx-tg-task3"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
  health_check {
    path = "/"
    port = "80"
  }
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

output "alb_dns_name" { value = aws_lb.nginx.dns_name }
