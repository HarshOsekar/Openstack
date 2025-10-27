variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type. Ensure it has >=4 vCPU and ~8GB RAM (e.g. t3.xlarge has 4 vCPU)."
  type        = string
  default     = "t3.xlarge"
}

variable "ssh_key_name" {
  description = "Existing AWS key pair name to attach to the instance (you must create this in the AWS console or with aws cli beforehand)."
  type        = string
  default     = "amazon_linux"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_key_path" {
  description = "Path to your SSH private key (.pem)"
  type        = string
}
