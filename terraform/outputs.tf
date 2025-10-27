output "instance_public_ip" {
  description = "Public IP of the DevStack controller instance"
  value       = aws_instance.devstack_controller.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the DevStack controller instance"
  value       = aws_instance.devstack_controller.private_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.devstack_controller.id
}