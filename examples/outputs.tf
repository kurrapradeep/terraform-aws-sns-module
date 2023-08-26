################################################################################
# Complete
################################################################################

output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = module.sns_topic.topic_arn
}

output "sns_topic_id" {
  description = "The ARN of the SNS topic"
  value       = module.sns_topic.topic_id
}

output "sns_topic_name" {
  description = "The name of the topic"
  value       = module.sns_topic.topic_name
}

output "sns_topic_owner" {
  description = "The AWS Account ID of the SNS topic owner"
  value       = module.sns_topic.topic_owner
}

output "sns_subscriptions" {
  description = "Map of subscriptions created and their attributes"
  value       = module.sns_topic.subscriptions
}
