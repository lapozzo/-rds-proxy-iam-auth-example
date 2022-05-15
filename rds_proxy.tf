resource "aws_db_proxy" "rds_proxy" {
  count                  = var.rds_proxy_enabled ? 1 : 0
  name                   = "rdsproxy"
  debug_logging          = true
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy_iam_role[0].arn
  vpc_security_group_ids = [aws_security_group.allow_mysql[0].id]
  vpc_subnet_ids         = [aws_subnet.subnet_a[0].id, aws_subnet.subnet_b[0].id]

  auth {
    auth_scheme = "SECRETS"
    description = "rdsproxy"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_secretsmanager_secret.rds_secret[0].arn
  }
}

resource "aws_db_proxy_default_target_group" "rds_proxy_target_group" {
  count         = var.rds_proxy_enabled ? 1 : 0
  db_proxy_name = aws_db_proxy.rds_proxy[0].name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 10
    max_idle_connections_percent = 5
  }
}

resource "aws_db_proxy_target" "rds_proxy_target" {
  count                  = var.rds_proxy_enabled ? 1 : 0
  db_instance_identifier = aws_db_instance.default[0].id
  db_proxy_name          = aws_db_proxy.rds_proxy[0].name
  target_group_name      = aws_db_proxy_default_target_group.rds_proxy_target_group[0].name
}

resource "random_string" "random" {
  length           = 8
  special          = false
  override_special = "/@£$"
}

resource "aws_secretsmanager_secret" "rds_secret" {
  count = var.rds_proxy_enabled ? 1 : 0
  name  = "rdssecret-${random_string.random.result}"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count     = var.rds_proxy_enabled ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_secret[0].id
  secret_string = jsonencode({
    "username"             = "${var.username}"
    "password"             = "${var.password}"
    "engine"               = "mysql"
    "host"                 = aws_db_instance.default[0].address
    "port"                 = 3306
    "dbInstanceIdentifier" = aws_db_instance.default[0].id
  })
}

resource "aws_cloudwatch_log_group" "rds_proxy_log_group" {
  count = var.rds_proxy_enabled ? 1 : 0

  name              = "/aws/rds/proxy/rdsproxy"
  retention_in_days = 7
}
