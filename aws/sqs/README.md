# SQS Module

This module will build and configure an [Amazon SQS](https://aws.amazon.com/sqs/) queue

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Dead-Letter Queue](#dead-letter-queue)
    - [Lambda Triggers](#lambda-triggers)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-sqs.git?ref=v1.0.0"

  name = "demo-sqs"

  access_policy = jsonencode({
    # You must explicitly specify this version, otherwise, AWS will hang indefinitely
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::111122223333:root"
        }
        Action   = "SQS:*"
        Resource = "arn:aws:sqs:us-east-1:111122223333:demo-sqs"
      }
    ]
  })
}
```

### Dead-Letter Queue

```terraform
module "dead_letter_queue" {
  source = "github.com/FriendsOfTerraform/aws-sqs.git?ref=v1.0.0"

  name              = "demo-sqs"
  dead_letter_queue = { arn = module.dead_letter_queue_destination.sqs_queue_arn }
}

module "dead_letter_queue_destination" {
  source = "github.com/FriendsOfTerraform/aws-sqs.git?ref=v1.0.0"

  name                 = "demo-dlq"
  redrive_allow_policy = ["arn:aws:sqs:us-east-1:111122223333:demo-sqs"]
}
```

### Lambda Triggers

The following example demonstrates how to enable [Lambda enhanced monitoring][lambda-enhanced-monitoring]. This feature requires the LambdaInsightsExtension, you can get a list of available versions [from here][lambda-insight-extension-versions].

```terraform
module "lambda_triggers" {
  source = "github.com/FriendsOfTerraform/aws-sqs.git?ref=v1.0.0"

  name = "demo-sqs"

  lambda_triggers = {
    # The key of the map is the ARN of the Lambda function to trigger
    # All messages received will trigger the Lambda function general-function
    "arn:aws:lambda:us-east-1:111122223333:function:general-function" = {}

    # Only messages with the body matching the pattern will trigger the Lambda function temperature-function
    "arn:aws:lambda:us-east-1:111122223333:function:temperature-function" = {
      filter_criteria = {
        patterns = [
          jsonencode({ Temperature = [{ numeric = [">", 0, "<=", 100] }] })
        ]
      }
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the SQS queue. All associated resources' names will also be prefixed by this value. If the name is suffixed with `".fifo"`, a FIFO queue will be created. For example: `"demo-sqs.fifo"`

### Optional

- (string) **`access_policy = null`** _[since v1.0.0]_

    A JSON document that defines the accounts, users and roles that can access this queue, and the actions that are allowed. Note that you MUST explicitly set `Version = "2012-10-17"` in the policy document otherwise AWS will hang indefinitely. [See example](#basic-usage)

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the SQS queue

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (object) **`dead_letter_queue = null`** _[since v1.0.0]_

    A destination SQS queue for messages that failed to be consumed successfully. [See example](#dead-letter-queue)

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the destination SQS queue

    - (number) **`maximum_receives = 10`** _[since v1.0.0]_

        The number of times a consumer can receive a message from a source queue before it is moved to a dead-letter queue

- (string) **`delivery_delay = "0 second"`** _[since v1.0.0]_

    Specify the amount of time to delay the first delivery of each message added to the queue. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`. Valid value: `"0 second"` - `"15 minutes"`

- (object) **`enable_server_side_encryption_kms = null`** _[since v1.0.0]_

    Enable SSE KMS encryption. If not specified, SSE SQS is enabled by default

    - (string) **`data_key_reuse_period = "5 minutes"`** _[since v1.0.0]_

        The time period in which Amazon SQS can cache and use a data key before calling KMS again to obtain a new data key. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`. Valid value: `"1 minute"` - `"24 hours"`

    - (string) **`kms_key_id = "alias/aws/sqs"`** _[since v1.0.0]_

        The KMS key to be used for encryption

- (object) **`fifo_queue_settings = null`** _[since v1.0.0]_

    Configuration options that apply to FIFO SQS queue

    - (bool) **`enable_content_based_deduplication = false`** _[since v1.0.0]_

        When enabled, the message deduplication ID is optional.

    - (string) **`deduplication_scope = "queue"`** _[since v1.0.0]_

        Specify the scope of deduplication for a FIFO queue. Valid values: `"queue"`, `"messageGroup"`

    - (string) **`fifo_throughput_limit = "perQueue"`** _[since v1.0.0]_

        Specify how to apply the throughput limit on FIFO queue. Valid values: `"perQueue"`, `"perMessageGroupId"`

- (map(object)) **`lambda_triggers = {}`** _[since v1.0.0]_

    Configure the queue to trigger an AWS Lambda function when new messages arrive in the queue. [See example](#lambda-triggers)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags associated to the lambda trigger

    - (number) **`batch_size = 10`** _[since v1.0.0]_

        The maximum number of records in each batch to send to the function. The maximum is `10000` for standard queues and `10` for FIFO queues.

    - (number) **`batch_window = 0`** _[since v1.0.0]_

        The maximum amount of time to gather records before invoking the function, in seconds. When the batch size is greater than 10, set the batch window to at least 1 second.

    - (bool) **`enable_metrics = false`** _[since v1.0.0]_

        Monitor your event source with metrics. You can view those metrics in CloudWatch console. Enabling this feature incurs additional costs

    - (bool) **`enabled = true`** _[since v1.0.0]_

        Whether this lambda trigger is enabled

    - (object) **`filter_criteria = null`** _[since v1.0.0]_

        Define the filtering criteria to determine whether or not to process an event

      - (list(string)) **`patterns`** _[since v1.0.0]_

          You can specify up to 5 filter patterns. Please refer to [this documentation][lambda-event-source-mapping-filter-rule-syntax] for a list of valid filter syntaxs

      - (string) **`kms_key_arn = null`** _[since v1.0.0]_

          The KMS key to encrypt and decrypt the filter criteria

    - (number) **`maximum_concurrency = 100`** _[since v1.0.0]_

        The maximum number of concurrent function instances that the SQS event source can invoke. Valid values: `2 - 1000`

    - (bool) **`report_batch_item_failures = false`** _[since v1.0.0]_

        Allow your function to return a partial successful response for a batch of records.

- (number) **`maximum_message_size = 256`** _[since v1.0.0]_

    The maximum message size, in Kibibytes (KiB), for your queue. Valid value: `1 - 256`

- (string) **`message_retention_period = "4 days"`** _[since v1.0.0]_

    The amount of time that Amazon SQS retains a message that does not get deleted. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`, `"days"`. Valid value: `"1 minute"` - `"14 days"`

- (number) **`receive_message_wait_time = 0`** _[since v1.0.0]_

    The maximum amount of time, in seconds, that polling will wait for messages to become available to receive. Valid value: `0 - 20`

- (list(string)) **`redrive_allow_policy = null`** _[since v1.0.0]_

    Specify which source SQS queues can use this queue as the destination dead-letter queue. [See example](#dead-letter-queue)

- (string) **`visibility_timeout = "30 seconds"`** _[since v1.0.0]_

    Specify the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`, `"hours"`. Valid value: `"0 second"` - `"12 hours"`

## Outputs

- (string) **`sqs_queue_arn`** _[since v1.0.0]_

    The ARN of the SQS queue

- (string) **`sqs_queue_id`** _[since v1.0.0]_

    The URL of the SQS queue

- (string) **`sqs_queue_url`** _[since v1.0.0]_

    The URL of the SQS queue. Same as `sqs_queue_id`

[lambda-event-source-mapping-filter-rule-syntax]:https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html#invocation-async-destinations
