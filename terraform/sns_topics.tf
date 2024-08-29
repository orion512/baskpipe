resource "aws_sns_topic" "sf_daily_baskref_notification" {
  name = "sf-daily-baskref-notification"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sf_daily_baskref_notification.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.sf_daily_baskref_notification.arn
  protocol  = "sms"
  endpoint  = var.notification_phone_number
}

