
resource "aws_sfn_state_machine" "nba_daily_games_baskref" {
  name     = "nba-daily-games-baskref"
  role_arn = aws_iam_role.stepf_nba_daily_games_baskref_role.arn

  # the below configuration of a step function reads from a file instead of being defined inline
  # for this reason we have to use string interpolation for variables
  definition = templatefile("step_daily_games.json", {
    baskpipe_daily_scrape_arn = aws_lambda_function.baskpipe_daily_scrape.arn,
    sql_execute_arn           = aws_lambda_function.sql_execute.arn,
    sns_topic_arn             = aws_sns_topic.sf_daily_baskref_notification.arn
  })
  
}
