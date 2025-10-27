terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "devstack_sg" {
  name        = "devstack-sg"
  description = "Allow SSH and ICMP (ping)"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devstack-sg"
  }
}

resource "aws_instance" "devstack_controller" {
  ami                    = "ami-07f07a6e1060cd2a8"
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name != "" ? var.ssh_key_name : null
  vpc_security_group_ids = [aws_security_group.devstack_sg.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "5m" # Increase timeout for DevStack installation
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for system to stabilize...'",
      "sleep 30",
      "sudo apt-get update -y",
      "sudo apt-get install -y git",
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y",
      "sudo apt install -y git",
      "git clone https://opendev.org/openstack/devstack /home/ubuntu/devstack",
      "echo '[[local|localrc]]\nADMIN_PASSWORD=pass\nDATABASE_PASSWORD=pass\nRABBIT_PASSWORD=pass\nSERVICE_PASSWORD=pass\nHOST_IP=${self.private_ip}' > /home/ubuntu/devstack/local.conf",
      "sudo -H -u ubuntu bash -c 'cd /home/ubuntu/devstack && nohup ./stack.sh > /home/ubuntu/devstack_install.log 2>&1'"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for DevStack installation to complete...'",
      "if grep -q \"Horizon is now available at http://${self.private_ip}/dashboard\" /home/ubuntu/devstack_install.log; then echo \"✅ DevStack installation verified! Horizon dashboard is available.\"; else echo \"❌ DevStack installation failed or not completed. Check logs.\" && exit 1; fi",
      "echo 'http://${self.public_ip}/dashboard'"
    ]
  }
}