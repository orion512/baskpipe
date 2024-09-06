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
