resource "aws_cloudwatch_event_rule" "sf_daily_games_failure_rule" {
  name        = "sf-daily-games-failure-rule"
  description = "Trigger SNS notification on Step Function failure for baskpipe daily games pipeline"
  event_pattern = jsonencode({
    "source": [
      "aws.states"
    ],
    "detail-type": [
      "Step Functions Execution Status Change"
    ],
    "detail": {
      "status": [
        "FAILED"
      ],
      "stateMachineArn": [
        aws_sfn_state_machine.baskpipe_daily_games_baskref.arn
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "sf_daily_games_failure_target" {
  rule      = aws_cloudwatch_event_rule.sf_daily_games_failure_rule.name
  arn       = aws_sns_topic.sf_daily_baskref_notification.arn
}

resource "aws_cloudwatch_event_rule" "baskpipe_daily_rule" {
  name                = "baskpipe-daily-rule"
  schedule_expression = "cron(30 7 * * ? *)"  # Runs every day at 7:30 UTC
}

resource "aws_lambda_permission" "baskpipe-allow-eventbridge-daily" {
  statement_id  = "AllowExecutionFromEventBridgeDaily"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_daily_scrape.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.baskpipe_daily_rule.arn
}

resource "aws_cloudwatch_event_target" "baskpipe_daily_rule_target" {
  rule      = aws_cloudwatch_event_rule.baskpipe_daily_rule.name
  target_id = "trigger-daily-scrape-lambda-daily"
  arn       = aws_lambda_function.trigger_daily_scrape.arn
}
