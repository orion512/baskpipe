resource "aws_lambda_function" "baskpipe_daily_scrape" {
    function_name = "baskpipe-daily-scrape"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/baskpipe-daily-scrape.zip"

    role = aws_iam_role.baskpipe_lambda_role.arn

    timeout = 90
}

resource "aws_lambda_function" "sql_execute" {
    function_name = "sql-execute"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/sql-execute.zip"

    role = aws_iam_role.baskpipe_lambda_role.arn

    timeout = 900

    environment {
        variables = {
        DB_SECRET_NAME = aws_secretsmanager_secret.baskpipe_db_secret.name
        }
    }
}

resource "aws_lambda_function" "s3_to_postgres" {
    function_name = "s3-to-postgres"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/s3-to-postgres.zip"

    role = aws_iam_role.baskpipe_lambda_role.arn

    timeout = 900

    environment {
        variables = {
        DB_SECRET_NAME = aws_secretsmanager_secret.baskpipe_db_secret.name
        }
    }
}

resource "aws_lambda_function" "trigger_daily_scrape" {
    function_name = "trigger-daily-scrape"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/trigger-daily-scrape.zip"

    role = aws_iam_role.baskpipe_lambda_trigger_role.arn

    timeout = 60

    environment {
        variables = {
            STEP_FUNCTION_ARN = aws_sfn_state_machine.baskpipe_daily_games_baskref.arn
        }
    }
}
