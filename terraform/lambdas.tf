resource "aws_lambda_function" "baskpipe_daily_scrape" {
    function_name = "baskpipe-daily-scrape"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/baskpipe-daily-scrape.zip"

    role = "arn:aws:iam::856342935636:role/service-role/baskpipe-daily-scrape-role-utzlfsbn"

    timeout = 90
}

resource "aws_lambda_function" "sql_execute" {
    function_name = "sql-execute"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/sql-execute.zip"

    role = aws_iam_role.sql_execute_role.arn

    timeout = 900
}

resource "aws_lambda_function" "s3_to_postgres" {
    function_name = "s3-to-postgres"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/s3-to-postgres.zip"

    # use same role as for SQL execute
    role = aws_iam_role.sql_execute_role.arn

    timeout = 900
}

