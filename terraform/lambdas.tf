resource "aws_lambda_function" "baskpipe-daily-scrape" {
    function_name = "baskpipe-daily-scrape"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    s3_bucket = "baskpipe"
    s3_key    = "lambdas/baskpipe-daily-scrape.zip"

    role = "arn:aws:iam::856342935636:role/service-role/baskpipe-daily-scrape-role-utzlfsbn"

    timeout = 90
}
