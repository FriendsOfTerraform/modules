# Simple Notification Service Module

This module creates and configures an [SNS](https://aws.amazon.com/sns/) topic and multiple subscriptions

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Data Protection Policy](#data-protection-policy)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
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
        "marketing@examplecorp.com"
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

The name of the SNS topic. All associated resources will also have their name prefixed with this value

    

    

    

    

    
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

Defines who can access the topic. By default, only the topic owner can publish or subscribe to the topic

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the SNS topic

    

    

    

    

    
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
    <td><code>object(<a href="#dataprotectionpolicy">DataProtectionPolicy</a>)</code></td>
    <td width="100%">data_protection_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manages the [data protection policy][sns-data-protection-policy] for this topic.

    

    

    
**Examples:**
- [Data Protection Policy](#data-protection-policy)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#deliverypolicy">DeliveryPolicy</a>)</code></td>
    <td width="100%">delivery_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Topic wide delivery policy that tells SNS how to retry failed message deliveries to endpoints with the `http`, `https` protocol

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#deliverystatuslogging">DeliveryStatusLogging</a>)</code></td>
    <td width="100%">delivery_status_logging</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables logging of the delivery status of notification messages sent to topics

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">display_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The display name of the topic. Optional for all transports. For SMS subscriptions only the first 10 characters are used. If not specified, the `name` of the topic will be used.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_active_tracing</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enable to have AWS X-Ray collect data about the messages that this topic receives. Additional steps are needed, please see [Active Tracing X-Ray resource-based policy](#active-tracing-x-ray-resource-based-policy)

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_content_based_message_deduplication</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enable default message deduplication based on message content. If false, a deduplication ID must be provided for every publish request

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableencryption">EnableEncryption</a>)</code></td>
    <td width="100%">enable_encryption</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables SNS encryption at-rest

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#subscriptions">Subscriptions</a>))</code></td>
    <td width="100%">subscriptions</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

Manages multiple subscriptions for this topic.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">sns_topic_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the SNS topic

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">sns_topic_subscription_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARNs of the subscribers for this SNS topic

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### Audit

Audit matching sensitive data and send audit result to a destination

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">sample_rate</td>
    <td></td>
</tr>
<tr><td colspan="3">

The percentage of messages to audit for sensitive information. Valid value: between `0` to `99`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#destinations">Destinations</a>)</code></td>
    <td width="100%">destinations</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS services to send the audit finding results. Must specify at least one of the following: `cloudwatch_log_group`, `s3_bucket_name`, `firehose_delivery_stream`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Configuration

Define Custom Data identifiers that can be used in data protection policy

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">custom_data_identifiers</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of custom data identifiers in `{Name = Regex}` format

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DataProtectionPolicy



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#statements">Statements</a>))</code></td>
    <td width="100%">statements</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages multiple statements in this policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#configuration">Configuration</a>)</code></td>
    <td width="100%">configuration</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Define Custom Data identifiers that can be used in data protection policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Deidentify

De-identify matching sensitive data by either redacting them or masking them with a specific character. Must specify one and only one of the following: `mask_with_character`, `redact`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">mask_with_character</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Replaces the data with single characters. All printable ASCII characters except delete are supported

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">redact</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Completely removes the data

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DeliveryPolicy



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">disable_subscription_overrides</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>object(<a href="#healthyretrypolicy">HealthyRetryPolicy</a>)</code></td>
    <td width="100%">healthy_retry_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Define the retry policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#throttlepolicy">ThrottlePolicy</a>)</code></td>
    <td width="100%">throttle_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Define the throttle policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#requestpolicy">RequestPolicy</a>)</code></td>
    <td width="100%">request_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Define the request policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DeliveryStatusLogging



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">protocols</td>
    <td></td>
</tr>
<tr><td colspan="3">

Subscriber protocols which logs will be generated for.

    
**Allowed Values:**
- `application`
- `http`
- `lambda`
- `sqs`
- `firehose`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">success_sample_rate</td>
    <td></td>
</tr>
<tr><td colspan="3">

The percentage of successful message deliveries to log. Valid value: between `0` and `100`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_for_successful_deliveries</td>
    <td></td>
</tr>
<tr><td colspan="3">

Arn of an IAM role that gives permission to SNS to write successful delivery logs to Cloudwatch

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_for_failed_deliveries</td>
    <td></td>
</tr>
<tr><td colspan="3">

Arn of an IAM role that gives permission to SNS to write failed delivery logs to Cloudwatch

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Destinations

The AWS services to send the audit finding results. Must specify at least one of the following: `cloudwatch_log_group`, `s3_bucket_name`, `firehose_delivery_stream`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cloudwatch_log_group</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The Cloudwatch log group to send audit results to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">s3_bucket_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of an S3 bucket to send audit results to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">firehose_delivery_stream</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of a Kinese Firehose Delivery Stream to send audit results to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableEncryption



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td><code>"alias/aws/sns"</code></td>
</tr>
<tr><td colspan="3">

The ID of a KMS key used for encryption

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### HealthyRetryPolicy

Define the retry policy

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">min_delay_target</td>
    <td><code>20</code></td>
</tr>
<tr><td colspan="3">

The minimum delay for a retry in seconds. Valid value: between `1` and `max_delay_target`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_delay_target</td>
    <td><code>20</code></td>
</tr>
<tr><td colspan="3">

The maximum delay for a retry in seconds. Valid value: between `min_delay_target` and `3600`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">num_retries</td>
    <td><code>3</code></td>
</tr>
<tr><td colspan="3">

The total number of retries, including immediate, pre-backoff, backoff, and post-backoff retries. Valid value: between `0` to `100`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">num_no_delay_retries</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The number of retries to be done immediately, with no delay between them

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">num_min_delay_retries</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The number of retries in the pre-backoff phase, with the specified `min_delay_target` between them

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">num_max_delay_retries</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The number of retries in the post-backoff phase, with the `max_delay_target` between them.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">backoff_function</td>
    <td><code>"linear"</code></td>
</tr>
<tr><td colspan="3">

The model for backoff between retries.

    
**Allowed Values:**
- `arithmetic`
- `exponential`
- `geometric`
- `linear`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Operation

The [operation to trigger][sns-data-protection-policy-operations] upon finding sensitive data as specified by this statement. You must specify one and only one of the following: `audit`, `deidentify`, `deny`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#audit">Audit</a>)</code></td>
    <td width="100%">audit</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Audit matching sensitive data and send audit result to a destination

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#deidentify">Deidentify</a>)</code></td>
    <td width="100%">deidentify</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

De-identify matching sensitive data by either redacting them or masking them with a specific character. Must specify one and only one of the following: `mask_with_character`, `redact`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#deny">Deny</a>)</code></td>
    <td width="100%">deny</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Denies the delivery of the message if the message contains sensitive data

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RequestPolicy

Define the request policy

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">header_content_type</td>
    <td><code>"text/plain; charset=UTF-8"</code></td>
</tr>
<tr><td colspan="3">

The content type of the notification being sent to HTTP/S endpoints.

    
**Allowed Values:**
- `application/json`
- `text/plain`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Statements

Manages multiple statements in this policy

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">data_direction</td>
    <td></td>
</tr>
<tr><td colspan="3">

The direction of messages to which this statement applies.

    
**Allowed Values:**
- `Inbound`
- `Outbound`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">data_identifiers</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of data identifiers that represent sensitive data this statement applies to. Please refer to [this documentation][sns-managed-data-identifier] for the valid values. Can also include names specified in the `data_protection_policy.configuration.custom_data_identifiers`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">principals</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of IAM principals this statement applies to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#operation">Operation</a>)</code></td>
    <td width="100%">operation</td>
    <td></td>
</tr>
<tr><td colspan="3">

The [operation to trigger][sns-data-protection-policy-operations] upon finding sensitive data as specified by this statement. You must specify one and only one of the following: `audit`, `deidentify`, `deny`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Subscriptions



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td></td>
</tr>
<tr><td colspan="3">

The type of endpoint to subscribe.

    
**Allowed Values:**
- `application`
- `firehose`
- `lambda`
- `sms`
- `sqs`
- `email`
- `http`
- `https`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">endpoints</td>
    <td></td>
</tr>
<tr><td colspan="3">

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

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dead_letter_queue_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN of a SQS queue where SNS will forward messages that can't be delivered to subscribers successfully to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_raw_message_delivery</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to enable raw message delivery, where the original message is directly passed and not wrapped in JSON with the original message in the message property

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">filter_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

JSON String with the [filter policy][sns-subscription-filter-policy] that will be used in the subscription to filter messages seen by the target resource

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">filter_policy_scope</td>
    <td><code>"MessageAttributes"</code></td>
</tr>
<tr><td colspan="3">

The [filter policy scope][sns-subscription-filter-policy-scope].

    
**Allowed Values:**
- `MessageAttributes`
- `MessageBody`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">subscription_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN of the IAM role to publish to Kinesis Data Firehose delivery stream. Required only if `protocol = "firehose"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ThrottlePolicy

Define the throttle policy

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">max_receives_per_second</td>
    <td></td>
</tr>
<tr><td colspan="3">

The maximum number of deliveries per second, per subscription. Valid value: `1` or greater

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[sns-data-protection-policy]: https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-policies.html

[sns-data-protection-policy-operations]: https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-operations.html#statement-operation-json-properties-deidentify

[sns-managed-data-identifier]: https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-managed-data-identifiers.html#what-are-data-managed-data-identifiers

[sns-subscription-filter-policy]: https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html

[sns-subscription-filter-policy-scope]: https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering-scope.html


<!-- TFDOCS_EXTRAS_END -->

## Known Limitations

### Active Tracing X-Ray resource-based policy

There is no way to create the X-ray resource-based policy required for the SNS active tracing with Terraform today. Therefore, after enabling active tracing in this module, you must follow [this documentation][sns-active-tracing-xray] to create the resource-based policy using different means.

[sns-active-tracing-xray]:https://docs.aws.amazon.com/xray/latest/devguide/xray-services-sns.html
[sns-data-protection-policy]:https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-policies.html
