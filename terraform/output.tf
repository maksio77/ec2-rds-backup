output "ec2-address" {
  description = "Public IP PgAdmin"
  value       = aws_instance.my-instance.public_ip
}

output "rds-host" {
  description = "RDS hostname"
  value       = aws_db_instance.pg.address
}
