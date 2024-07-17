# Simple Notification Service Module

This module creates and configures an [SNS](https://aws.amazon.com/sns/) topic and multiple subscriptions

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Data Protection Policy](#data-protection-policy)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
    - [Active Tracing X-Ray resource-based policy](#active-tracing-x-ray-resource-based-policy)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-sns.git?ref=v1.0.0"

  name = "demo-sns"

  subscriptions = [
    # endpoints will the same configuration should be grouped in the same object
    # Sales and Marketing team gets notified whenever there is a cancelled order
    {
      protocol = "email"
      endpoints = [
        "sales@examplecorp.com",
        "marketing@examplecorp.com
      ]

      filter_policy = jsonencode(
        {
          event = ["order_cancelled"]
        }
      )
    },

    # all messages get sent to the analysis email
    {
      protocol = "email"
      endpoints = [
        "analysis@examplecorp.com"
      ]
    }
  ]
}
```

### Data Protection Policy

Manages the [data protection policy][sns-data-protection-policy]

```terraform
module "data_protection_policy" {
  source = "github.com/FriendsOfTerraform/aws-sns.git?ref=v1.0.0"

  name = "demo-sns"

  data_protection_policy = {
    # The keys of the map will be the SID of each statement
    statements = {
      "audit_aws_secret_key" = {
        data_direction   = "Inbound"
        data_identifiers = ["arn:aws:dataprotection::aws:data-identifier/AwsSecretKey"]

        operation = {
          audit = {
            sample_rate = 10

            destinations = {
              s3_bucket_name       = "test-bucket"
              cloudwatch_log_group = "/aws/vendedlogs/test"
            }
          }
        }
      }

      # Mask DB password with #
      "mask_db_password" = {
        data_direction   = "Inbound"
        data_identifiers = ["db-password"]

        operation = {
          deidentify = {
            mask_with_character = "#"
          }
        }
      }
    }

    configuration = {
      custom_data_identifiers = {
        db-password = "dbpass.*"
      }
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the SNS topic. All associated resources will also have their name prefixed with this value

### Optional

- (string) **`access_policy = null`** _[since v1.0.0]_

    Defines who can access the topic. By default, only the topic owner can publish or subscribe to the topic

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the SNS topic

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (object) **`data_protection_policy = null`** _[since v1.0.0]_

    Manages the [data protection policy][sns-data-protection-policy] for this topic. Please [see example](#data-protection-policy)

    - (map(object)) **`statements`** _[since v1.0.0]_

        Manages multiple statements in this policy

        - (string) **`data_direction`** _[since v1.0.0]_

            The direction of messages to which this statement applies. Valid value: `"Inbound"`, `"Outbound"`

        - (list(string)) **`data_identifiers`** _[since v1.0.0]_

            A list of data identifiers that represent sensitive data this statement applies to. Please refer to [this documentation][sns-managed-data-identifier] for the valid values. Can also include names specified in the `data_protection_policy.configuration.custom_data_identifiers`

        - (object) **`operation`** _[since v1.0.0]_

            The [operation to trigger][sns-data-protection-policy-operations] upon finding sensitive data as specified by this statement. You must specify one and only one of the following: `audit`, `deidentify`, `deny`

            - (object) **`audit = null`** _[since v1.0.0]_

                Audit matching sensitive data and send audit result to a destination

                - (number) **`sample_rate`** _[since v1.0.0]_

                    The percentage of messages to audit for sensitive information. Valid value: between `0` to `99`

                - (object) **`destinations`** _[since v1.0.0]_

                    The AWS services to send the audit finding results. Must specificy at least one of the following: `cloudwatch_log_group`, `s3_bucket_name`, `firehose_delivery_stream`

                    - (string) **`cloudwatch_log_group = null`** _[since v1.0.0]_

                        The Cloudwatch log group to send audit results to

                    - (string) **`firehose_delivery_stream = null`** _[since v1.0.0]_

                        The name of a Kinese Firehose Delivery Stream to send audit results to

                    - (string) **`s3_bucket_name = null`** _[since v1.0.0]_

                        The name of an S3 bucket to send audit results to

            - (object) **`deidentify = null`** _[since v1.0.0]_

                De-identify matching sensitive data by either redacting them or masking them with a specific character. Must specify one and only one of the following: `mask_with_character`, `redact`

                - (string) **`mask_with_character = null`** _[since v1.0.0]_

                    Replaces the data with single characters. All printable ASCII characters except delete are supported

                - (bool) **`redact = null`** _[since v1.0.0]_

                    Completely removes the data

            - (object) **`deny = null`** _[since v1.0.0]_

                Denies the delivery of the message if the message contains sensitive data

        - (list(string)) **`principals = ["*"]`** _[since v1.0.0]_

            A list of IAM principals this statement applies to

    - (object) **`configuration = null`** _[since v1.0.0]_

        Define Custom Data identifiers that can be used in data protection policy

        - (map(string)) **`custom_data_identifiers`** _[since v1.0.0]_

            Map of custom data identifiers in `{Name = Regex}` format

- (object) **`delivery_policy = null`** _[since v1.0.0]_

    Topic wide delivery policy that tells SNS how to retry failed message deliveries to endpoints with the `http`, `https` protocol

    - (object) **`healthy_retry_policy = null`** _[since v1.0.0]_

        Define the retry policy

        - (number) **`min_delay_target = 20`** _[since v1.0.0]_

            The minimum delay for a retry in seconds. Valid value: between `1` and `max_delay_target`

        - (number) **`max_delay_target = 20`** _[since v1.0.0]_

            The maximum delay for a retry in seconds. Valid value: between `min_delay_target` and `3600`

        - (number) **`num_retries = 3`** _[since v1.0.0]_

            The total number of retries, including immediate, pre-backoff, backoff, and post-backoff retries. Valid value: between `0` to `100`

        - (number) **`num_no_delay_retries = 0`** _[since v1.0.0]_

            The number of retries to be done immediately, with no delay between them

        - (number) **`num_min_delay_retries = 0`** _[since v1.0.0]_

            The number of retries in the pre-backoff phase, with the specified `min_delay_target` between them

        - (number) **`num_max_delay_retries = 0`** _[since v1.0.0]_

            The number of retries in the post-backoff phase, with the `max_delay_target` between them.

        - (string) **`backoff_function = "linear"`** _[since v1.0.0]_

            The model for backoff between retries. Valid values: `"arithmetic"`, `"exponential"`, `"geometric"`, `"linear"`

    - (object) **`throttle_policy = null`** _[since v1.0.0]_

        Define the throttle policy

        - (number) **`max_receives_per_second`** _[since v1.0.0]_

            The maximum number of deliveries per second, per subscription. Valid value: `1` or greater

    - (object) **`request_policy = null`** _[since v1.0.0]_

        Define the request policy

        - (string) **`header_content_type = "text/plain; charset=UTF-8"`** _[since v1.0.0]_

            The content type of the notification being sent to HTTP/S endpoints. Valid values: `"application/json"`, `"text/plain"`.

- (object) **`delivery_status_logging = null`** _[since v1.0.0]_

    Enables logging of the delivery status of notification messages sent to topics

    - (list(string)) **`protocols`** _[since v1.0.0]_

        Subscriber protocols which logs will be generated for. Valid values: `"application"`, `"http"`, `"lambda"`, `"sqs"`, `"firehose"`

    - (number) **`success_sample_rate`** _[since v1.0.0]_

        The percentage of successful message deliveries to log. Valid value: between `0` and `100`

    - (string) **`iam_role_for_successful_deliveries`** _[since v1.0.0]_

        Arn of an IAM role that gives permission to SNS to write successful delivery logs to Cloudwatch

    - (string) **`iam_role_for_failed_deliveries`** _[since v1.0.0]_

        Arn of an IAM role that gives permission to SNS to write failed delivery logs to Cloudwatch

- (string) **`display_name = null`** _[since v1.0.0]_

    The display name of the topic. Optional for all transports. For SMS subscriptions only the first 10 characters are used. If not specified, the `name` of the topic will be used.

- (bool) **`enable_active_tracing = false`** _[since v1.0.0]_

    Enable to have AWS X-Ray collect data about the messages that this topic receives. Additional steps are needed, please see [Active Tracing X-Ray resource-based policy](#active-tracing-x-ray-resource-based-policy)

- (bool) **`enable_content_based_message_deduplication = false`** _[since v1.0.0]_

    Enable default message deduplication based on message content. If false, a deduplication ID must be provided for every publish request

- (object) **`enable_encryption = null`** _[since v1.0.0]_

    Enables SNS encryption at-rest

    - (string) **`kms_key_id = "alias/aws/sns"`** _[since v1.0.0]_

        The ID of a KMS key used for encryption

- (list(object)) **`subscriptions = []`** _[since v1.0.0]_

    Manages multiple subscriptions for this topic. [See example](#basic-usage)

    - (string) **`protocol`** _[since v1.0.0]_

        The type of endpoint to subscribe. Valid values: `"application"`, `"firehose"`, `"lambda"`, `"sms"`, `"sqs"`, `"email"`, `"email-json"`, `"http"`, `"https"`

    - (list(string)) **`endpoints`** _[since v1.0.0]_

        List of endpoints to send data to. The contents vary with the protocol. See details below:
        | Protocol    | Endpoint
        |-------------|---------------------------------------------------------
        | application | ARN of a mobile app and device
        | firehose    | ARN of an Amazon Kinesis Data Firehose delivery stream
        | lambda      | ARN of an AWS Lambda function
        | sms         | Phone number of an SMS-enabled device.
        | sqs         | ARN of an Amazon SQS queue
        | email       | An email address
        | email-json  | An email address
        | http        | A URL beginning with http://
        | https       | A URL beginning with https://

    - (string) **`dead_letter_queue_arn = null`** _[since v1.0.0]_

        ARN of a SQS queue where SNS will forward messages that can't be delivered to subscibers successfully to

    - (bool) **`enable_raw_message_delivery = false`** _[since v1.0.0]_

        Whether to enable raw message delivery, where the original message is directly passed and not wrapped in JSON with the original message in the message property

    - (string) **`filter_policy = null`** _[since v1.0.0]_

        JSON String with the [filter policy][sns-subscription-filter-policy] that will be used in the subscription to filter messages seen by the target resource

    - (string) **`filter_policy_scope = "MessageAttributes"`** _[since v1.0.0]_

        The [filter policy scope][sns-subscription-filter-policy-scope]. Valid values: `"MessageAttributes"`, `"MessageBody"`

    - (string) **`subscription_role_arn = null`** _[since v1.0.0]_

        ARN of the IAM role to publish to Kinesis Data Firehose delivery stream. Required only if `protocol = "firehose"`

## Outputs

- (string) **`sns_topic_arn`** _[since v1.0.0]_

    The ARN of the SNS topic

- (string) **`sns_topic_subscription_arns`** _[since v1.0.0]_

    The ARNs of the subscribers for this SNS topic

## Known Limitations

### Active Tracing X-Ray resource-based policy

There is no way to create the X-ray resource-based policy required for the SNS active tracing with Terraform today. Therefore, after enabling active tracing in this module, you must follow [this documentation][aws-active-tracing-xray] to create the resource-based policy using different means.

[sns-active-tracing-xray]:https://docs.aws.amazon.com/xray/latest/devguide/xray-services-sns.html
[sns-data-protection-policy]:https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-policies.html
[sns-data-protection-policy-operations]:https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-operations.html#statement-operation-json-properties-deidentify
[sns-managed-data-identifier]:https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-managed-data-identifiers.html#what-are-data-managed-data-identifiers
[sns-subscription-filter-policy]:https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html
[sns-subscription-filter-policy-scope]:https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering-scope.html
