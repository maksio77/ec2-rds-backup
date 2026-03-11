data "aws_ami" "ubuntu" {
  most_recent = true

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

  tags = {
    Name = "image-builder-instance"
  }
}
