resource "aws_db_instance" "default" {
  count                  = var.rds_enabled ? 1 : 0
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.27"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default[0].name
  vpc_security_group_ids = [aws_security_group.allow_mysql[0].id]
  port                   = 3306
  multi_az               = false
}

resource "aws_db_subnet_group" "default" {
  count      = var.rds_enabled ? 1 : 0
  name       = "main"
  subnet_ids = [aws_subnet.subnet_a[0].id, aws_subnet.subnet_b[0].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "allow_mysql" {
  count       = var.rds_enabled ? 1 : 0
  name        = "allow_mysql"
  description = "Allow Mysql inbound traffic"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    description = "TCP from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main[0].cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_mysql"
  }
}
