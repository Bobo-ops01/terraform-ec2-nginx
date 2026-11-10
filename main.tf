terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "my_ip" {
  description = "41.90.209.27/32"
  type        = string
}

variable "public_key" {
  description = "SSH public key"
  type        = string
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_key_pair" "demo" {
  key_name   = "terraform-demo-key"
  public_key = var.public_key
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "SSH from my IP, HTTP from anywhere"

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.demo.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Hello from Terraform on AWS</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "terraform-nginx-demo"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
