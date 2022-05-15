resource "aws_iam_role" "iam_for_lambda" {
  count = var.lambda_enabled ? 1 : 0
  name  = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  count       = var.lambda_enabled ? 1 : 0
  name        = "rdsproxylambdapolicy"
  description = "Lambda permissions for rds proxy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds-db:connect"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  count      = var.lambda_enabled ? 1 : 0
  role       = aws_iam_role.iam_for_lambda[0].name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}

resource "aws_lambda_function" "lambda_rds_proxy_test" {
  count            = var.lambda_enabled ? 1 : 0
  function_name    = "lambdards"
  filename         = "./app.zip"
  handler          = "app.lambda_handler"
  role             = aws_iam_role.iam_for_lambda[0].arn
  source_code_hash = filebase64sha256("./app.zip")
  runtime          = "python3.8"
  timeout          = 5
  memory_size      = 128

  environment {
    variables = {
      ENDPOINT                = aws_db_proxy.rds_proxy[0].endpoint
      PORT                    = "3306"
      USER                    = var.username
      DBNAME                  = "mydb"
      LOG_LEVEL               = "INFO"
      POWERTOOLS_SERVICE_NAME = "lambda_rds_proxy"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_a[0].id, aws_subnet.subnet_b[0].id]
    security_group_ids = [aws_security_group.allow_mysql[0].id]
  }

  tags = {
    Environment = "rdsproxy"
  }
}
