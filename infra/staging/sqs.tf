resource "aws_sqs_queue" "adjudication" {
  name                       = "${local.name_prefix}-adjudication"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 300
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.adjudication_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "adjudication_dlq" {
  name                      = "${local.name_prefix}-adjudication-dlq"
  message_retention_seconds = 604800
}
