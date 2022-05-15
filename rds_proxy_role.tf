data "aws_iam_policy_document" "assume_role" {
  count  = var.rds_proxy_enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_proxy_policy_document" {
  count  = var.rds_proxy_enabled ? 1 : 0
  statement {
    sid = "AllowProxyToGetDbCredsFromSecretsManager"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.rds_secret[0].arn
    ]
  }

  statement {
    sid = "AllowProxyToDecryptDbCredsFromSecretsManager"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["secretsmanager.${var.aws_region}.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}

resource "aws_iam_policy" "rds_proxy_iam_policy" {
  count  = var.rds_proxy_enabled ? 1 : 0
  name   = "rds-proxy-policy"
  policy = data.aws_iam_policy_document.rds_proxy_policy_document[0].json
}

resource "aws_iam_role_policy_attachment" "rds_proxy_iam_attach" {
  count      = var.rds_proxy_enabled ? 1 : 0
  policy_arn = aws_iam_policy.rds_proxy_iam_policy[0].arn
  role       = aws_iam_role.rds_proxy_iam_role[0].name
}

resource "aws_iam_role" "rds_proxy_iam_role" {
  count              = var.rds_proxy_enabled ? 1 : 0
  name               = "rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}
