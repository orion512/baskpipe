resource "aws_secretsmanager_secret" "baskpipe_db_secret" {
  name        = "baskpipe_db_secret"
  description = "Credentials for the PostgreSQL database"
}

resource "aws_secretsmanager_secret_version" "baskpipe_db_secret_version" {
  secret_id     = aws_secretsmanager_secret.baskpipe_db_secret.id
  secret_string = jsonencode({
    host     = aws_db_instance.baskpipedb.address
    port     = "5432"
    username = "baskpipebot"
    password = var.baskpipe_db_password
    dbname   = "baskpipedb"
  })
}
