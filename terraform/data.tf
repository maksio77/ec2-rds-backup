resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.main[*].id

  tags = {
    Name = "main-db-subnet-group"
  }
}

resource "aws_db_instance" "pg" {
  allocated_storage   = 20
  db_name             = "mypgdb"
  engine              = "postgres"
  engine_version      = "16"
  instance_class      = "db.t4g.micro"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}
