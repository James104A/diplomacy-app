resource "aws_sns_topic" "push_notifications" {
  name = "${local.name_prefix}-push-notifications"
}
