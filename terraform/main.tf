terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"
}

resource "aws_default_vpc" "default" {
}

variable "private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

resource "aws_instance" "my_instance" {
  ami           = "ami-042b4708b1d05f512"
  instance_type = "t3.micro"
  subnet_id = aws_default_vpc.default.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name = file(var.private_key_path)
  tags = {
    Name = "my-instance"
  }
}

resource "aws_ebs_volume" "my_volume" {
  availability_zone = aws_instance.my_instance.availability_zone
  size              = 8
  tags = {
    Name = "my-volume"
  }
}

resource "aws_volume_attachment" "my_attachment" {
  device_name = "dev/sdf"
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.my_instance.id
}

output "Instance_IP" {
  value = aws_instance.my_instance.public_ip
}