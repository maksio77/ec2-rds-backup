output "ec2-address" {
  description = "Public IP PgAdmin"
  value       = aws_instance.my-instance.public_ip
}
