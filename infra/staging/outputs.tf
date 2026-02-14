output "alb_dns_name" {
  description = "Public URL for the backend API"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for CI/CD image pushes"
  value       = aws_ecr_repository.backend.repository_url
}

output "rds_endpoint" {
  description = "RDS Postgres endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "sqs_adjudication_queue_url" {
  description = "SQS queue URL for adjudication jobs"
  value       = aws_sqs_queue.adjudication.url
}

output "sns_push_topic_arn" {
  description = "SNS topic ARN for push notifications"
  value       = aws_sns_topic.push_notifications.arn
}

output "s3_assets_bucket" {
  description = "S3 bucket name for static assets"
  value       = aws_s3_bucket.assets.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
