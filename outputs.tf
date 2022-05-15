output "rds_address" {
  value = aws_db_instance.default[0].address
}

output "rds_proxy_endpoint" {
  value = aws_db_proxy.rds_proxy[0].endpoint
}

output "vpc_cidr" {
  value = aws_vpc.main[0].cidr_block
}
