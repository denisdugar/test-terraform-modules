data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = var.secret_id
}

locals {
  db_cred = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}