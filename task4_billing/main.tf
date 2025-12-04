provider "aws" {
  region = "us-east-1"   # Billing alarms MUST be in us-east-1
}

resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "MonthlySpend-Exceeds-5-USD"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"  # 6 hours
  statistic           = "Maximum"
  threshold           = "5"
  alarm_description   = "Alarm when estimated charges exceed 5 USD"
  dimensions = {
    Currency = "USD"
  }
  alarm_actions = [aws_sns_topic.billing_alert.arn]
}

resource "aws_sns_topic" "billing_alert" {
  name = "billing-alert-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"   # ← CHANGE THIS TO YOUR REAL EMAIL
}
