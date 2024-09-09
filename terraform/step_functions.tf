
resource "aws_sfn_state_machine" "baskpipe_initdb" {
  name     = "baskpipe-initdb"
  role_arn = aws_iam_role.baskpipe_stepf_role.arn

  # the below configuration of a step function reads from a file instead of being defined inline
  # for this reason we have to use string interpolation for variables
  definition = templatefile("resources/step_init_db.asl.json", {
    sql_execute_arn           = aws_lambda_function.sql_execute.arn
  })
  
}

resource "aws_sfn_state_machine" "baskpipe_season_games_backfill" {
  name     = "baskpipe-season-games-backfill"
  role_arn = aws_iam_role.baskpipe_stepf_role.arn

  # the below configuration of a step function reads from a file instead of being defined inline
  # for this reason we have to use string interpolation for variables
  definition = templatefile("resources/step_season_games.asl.json", {
    sql_execute_arn           = aws_lambda_function.sql_execute.arn,
    s3_to_postgres_arn        = aws_lambda_function.s3_to_postgres.arn
  })
  
}

resource "aws_sfn_state_machine" "baskpipe_daily_games_baskref" {
  name     = "baskpipe-daily-games-baskref"
  role_arn = aws_iam_role.baskpipe_stepf_role.arn

  # the below configuration of a step function reads from a file instead of being defined inline
  # for this reason we have to use string interpolation for variables
  definition = templatefile("resources/step_daily_games.asl.json", {
    baskpipe_daily_scrape_arn = aws_lambda_function.baskpipe_daily_scrape.arn,
    sql_execute_arn           = aws_lambda_function.sql_execute.arn,
    s3_to_postgres_arn        = aws_lambda_function.s3_to_postgres.arn,
    sns_topic_arn             = aws_sns_topic.sf_daily_baskref_notification.arn
  })
  
}
