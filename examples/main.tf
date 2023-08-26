provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "exchangetopic"

  tags = {
    Name        = local.name
    Environment = "dev"
    Terraform   = true
  }
}

################################################################################
# SNS Module
################################################################################


module "sns_topic" {
  source = "../"
  name              = local.name
  display_name      = "exchangetopic"
  kms_master_key_id = module.kms.key_id
  tracing_config    = "Active"

  # SQS queue must be FIFO as well
  fifo_topic                  = true
  content_based_deduplication = true
  create_topic_policy         = true
  enable_default_topic_policy = true
  subscriptions = {
    sqs = {
      protocol            = "sqs"
      endpoint            = "arn:aws:sqs:us-east-1:067289050769:exchange-topic.fifo"
      filter_policy_scope = "MessageAttributes"
      filter_policy       = "{\"RoutingKey\": [\"Ratesheet\"]}"
    }
  }
  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases     = ["sns/${local.name}"]
  description = "KMS key to encrypt topic"

  # Policy
  key_statements = [
    {
      sid = "SNS"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      resources = ["*"]
      principals = [{
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }]
    }
  ]

  tags = local.tags
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.0"

  name       = local.name
  fifo_queue = true

  create_queue_policy = true
  queue_policy_statements = {
    sns = {
      sid     = "SNS"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]

      condition = {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [module.sns_topic.topic_arn]
      }
    }
  }

  tags = local.tags
}