# SQS Module

This module will build and configure an [Amazon SQS](https://aws.amazon.com/sqs/) queue

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Dead-Letter Queue](#dead-letter-queue)
  - [Lambda Triggers](#lambda-triggers)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the SQS queue. All associated resources' names will also be prefixed by this value. If the name is suffixed with `".fifo"`, a FIFO queue will be created. For example: `"demo-sqs.fifo"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A JSON document that defines the accounts, users and roles that can access this queue, and the actions that are allowed. Note that you MUST explicitly set `Version = "2012-10-17"` in the policy document otherwise AWS will hang indefinitely.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the SQS queue

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#deadletterqueue">DeadLetterQueue</a>)</code></td>
    <td width="100%">dead_letter_queue</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A destination SQS queue for messages that failed to be consumed successfully.

**Examples:**

- [Dead Letter Queue](#dead-letter-queue)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">delivery_delay</td>
    <td><code>"0 second"</code></td>
</tr>
<tr><td colspan="3">

Specify the amount of time to delay the first delivery of each message added to the queue. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`. Valid value: `"0 second"` - `"15 minutes"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#enableserversideencryptionkms">EnableServerSideEncryptionKms</a>)</code></td>
    <td width="100%">enable_server_side_encryption_kms</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enable SSE KMS encryption. If not specified, SSE SQS is enabled by default

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#fifoqueuesettings">FifoQueueSettings</a>)</code></td>
    <td width="100%">fifo_queue_settings</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configuration options that apply to FIFO SQS queue

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#lambdatriggers">LambdaTriggers</a>))</code></td>
    <td width="100%">lambda_triggers</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configure the queue to trigger an AWS Lambda function when new messages arrive in the queue.

**Examples:**

- [Lambda Triggers](#lambda-triggers)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_message_size</td>
    <td><code>256</code></td>
</tr>
<tr><td colspan="3">

The maximum message size, in Kibibytes (KiB), for your queue. Valid value: `1 - 256`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">message_retention_period</td>
    <td><code>"4 days"</code></td>
</tr>
<tr><td colspan="3">

The amount of time that Amazon SQS retains a message that does not get deleted. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`, `"days"`. Valid value: `"1 minute"` - `"14 days"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">receive_message_wait_time</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The maximum amount of time, in seconds, that polling will wait for messages to become available to receive. Valid value: `0 - 20`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">redrive_allow_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify which source SQS queues can use this queue as the destination dead-letter queue.

**Examples:**

- [Dead Letter Queue](#dead-letter-queue)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">visibility_timeout</td>
    <td><code>"30 seconds"</code></td>
</tr>
<tr><td colspan="3">

Specify the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers. In `"value unit"` format. Supported units: `"seconds"`, `"minutes"`, `"hours"`. Valid value: `"0 second"` - `"12 hours"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">sqs_queue_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the SQS queue

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">sqs_queue_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The URL of the SQS queue

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">sqs_queue_url</td>
    <td></td>
</tr>
<tr><td colspan="3">

The URL of the SQS queue. Same as `sqs_queue_id`

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### DeadLetterQueue

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the destination SQS queue

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_receives</td>
    <td><code>10</code></td>
</tr>
<tr><td colspan="3">

The number of times a consumer can receive a message from a source queue before it is moved to a dead-letter queue

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnableServerSideEncryptionKms

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">data_key_reuse_period</td>
    <td><code>"5 minutes"</code></td>
</tr>
<tr><td colspan="3">

The time period in which Amazon SQS can cache and use a data key before calling KMS again to obtain a new data key. In `"value unit"` format. Supported units: `"minutes"`, `"hours"`. Valid value: `"1 minute"` - `"24 hours"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td><code>"alias/aws/sqs"</code></td>
</tr>
<tr><td colspan="3">

The KMS key to be used for encryption

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### FifoQueueSettings

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_content_based_deduplication</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

When enabled, the message deduplication ID is optional.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">deduplication_scope</td>
    <td><code>"queue"</code></td>
</tr>
<tr><td colspan="3">

Specify the scope of deduplication for a FIFO queue.

**Allowed Values:**

- `queue`
- `messageGroup`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">fifo_throughput_limit</td>
    <td><code>"perQueue"</code></td>
</tr>
<tr><td colspan="3">

Specify how to apply the throughput limit on FIFO queue.

**Allowed Values:**

- `perQueue`
- `perMessageGroupId`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### FilterCriteria

Define the filtering criteria to determine whether or not to process an event

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">patterns</td>
    <td></td>
</tr>
<tr><td colspan="3">

You can specify up to 5 filter patterns. Please refer to [this documentation][lambda-event-source-mapping-filter-rule-syntax] for a list of valid filter syntaxes

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The KMS key to encrypt and decrypt the filter criteria

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### LambdaTriggers

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags associated to the lambda trigger

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">batch_size</td>
    <td><code>10</code></td>
</tr>
<tr><td colspan="3">

The maximum number of records in each batch to send to the function. The maximum is `10000` for standard queues and `10` for FIFO queues.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">batch_window</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The maximum amount of time to gather records before invoking the function, in seconds. When the batch size is greater than 10, set the batch window to at least 1 second.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_metrics</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Monitor your event source with metrics. You can view those metrics in CloudWatch console. Enabling this feature incurs additional costs

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether this lambda trigger is enabled

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#filtercriteria">FilterCriteria</a>)</code></td>
    <td width="100%">filter_criteria</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Define the filtering criteria to determine whether or not to process an event

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_concurrency</td>
    <td><code>100</code></td>
</tr>
<tr><td colspan="3">

The maximum number of concurrent function instances that the SQS event source can invoke. Valid values: `2 - 1000`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">report_batch_item_failures</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Allow your function to return a partial successful response for a batch of records.

**Since:** 1.0.0

</td></tr>
</tbody></table>

[lambda-event-source-mapping-filter-rule-syntax]: https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventfiltering.html#filtering-syntax

<!-- TFDOCS_EXTRAS_END -->
