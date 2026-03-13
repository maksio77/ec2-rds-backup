data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "my-instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-instance.id]

  user_data = templatefile("${path.module}/templates/ec2-setup.sh", {
    db_host        = aws_db_instance.pg.address
    db_username    = var.db_username
    pgadmin_passwd = var.pgadmin_passwd
  })

  tags = {
    Name = "image-builder-instance"
  }

  depends_on = [aws_db_instance.pg]
}
