resource "aws_vpc" "main" {
  count      = var.vpc_enabled ? 1 : 0
  cidr_block = "10.0.0.0/23"
  tags = {
    Name = "rds_vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  count             = var.vpc_enabled ? 1 : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet_a"
  }
}

resource "aws_subnet" "subnet_b" {
  count             = var.vpc_enabled ? 1 : 0
  vpc_id            = aws_vpc.main[0].id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "subnet_b"
  }
}
