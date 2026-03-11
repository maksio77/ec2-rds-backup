resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

locals {
  subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs     = ["${var.aws_region}a", "${var.aws_region}b"]
}

resource "aws_subnet" "main" {
  count = length(local.subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "main" {
  count = length(aws_subnet.main)

  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}
