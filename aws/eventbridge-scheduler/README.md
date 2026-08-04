# EventBridge Scheduler Module

This module will build and configure an [EventBridge](https://aws.amazon.com/eventbridge/) scheduler group and its associated schedules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-eventbridge-scheduler.git?ref=v1.0.0"

  name = "demo-schedule-group"

  # Manages multiple schedules for the schedule group
  schedules = {
    # The key of the map is the name of the schedule
    "ecs-task-rate-example" = {
      schedule_pattern = {
        rate_based_schedule = { rate_expression = "1 hour" }
      }

      target = {
        aws_api_action = "ecs:runTask"
        iam_role_arn   = "arn:aws:iam::111122223333:role/demo-eventbridge-scheduler"

        input = jsonencode({
          TaskDefinition  = "arn:aws:ecs:us-east-1:111122223333:task-definition/some-maintenance-ecs"
          Cluster         = "arn:aws:ecs:us-east-1:111122223333:cluster/demo"
          Count           = 1
          LaunchType      = "FARGATE"
          PlatformVersion = "LATEST"
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets = [
                "subnet-abcdef01234",
                "subnet-fedcba09876"
              ]
              SecurityGroups = [
                "sg-0914dd4bcaabcdef0"
              ]
              AssignPublicIp = "DISABLED"
            }
          }
          EnableECSManagedTags = false
        })
      }
    }

    "lambda-cron-example" = {
      schedule_pattern = {
        start_date_and_time = "2027-01-01T12:00:00Z"
        cron_based_schedule = { cron_expression = "0 13 * * ? *" }
      }

      target = {
        aws_api_action = "lambda:invoke"
        iam_role_arn   = "arn:aws:iam::111122223333:role/psin-test-eventbridge-scheduler"

        input = jsonencode({
          FunctionName   = "arn:aws:lambda:us-east-1:111122223333:function:demo-function",
          InvocationType = "Event"
        })
      }
    }

    "step-function-one-time-example" = {
      schedule_pattern = {
        one_time_schedule = { date_and_time = "2025-08-04T00:00:00" }
      }

      target = {
        aws_api_action = "sfn:startExecution"
        iam_role_arn   = "arn:aws:iam::111122223333:role/psin-test-eventbridge-scheduler"

        input = jsonencode({
          "StateMachineArn" : "arn:aws:states:us-east-1:111122223333:stateMachine:backup-step-function"
        })
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

The name of the schedule group

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#schedules">schedules</a>))</code></td>
    <td width="100%">schedules</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manage multiple schedules for the group.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the schedule group

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
</tbody></table>

## Objects

#### cron_based_schedule

A schedule set using a cron expression that runs at a specific time, such as every day 1 of the month, at 12:00AM.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cron_expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the cron expression for the schedule, for example: `"0 0 1 * *"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### one_time_schedule

A one-time schedule invokes it's target only once at the date, time, and in the time zone that you provide

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">date_and_time</td>
    <td></td>
</tr>
<tr><td colspan="3">

The date and time this schedule run, in `yyyy-mm-ddThh:mm:ss` format. For example: `"2030-01-01T01:00:00"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### rate_based_schedule

A rate-based schedule runs at a regular rate, such as every 10 minutes

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">rate_expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

The rate to invoke this trigger, in `value unit` format. For example: `"1 hour"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### retry_policy

Configures retry policy and dead-letter queue

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">maximum_age_of_event</td>
    <td><code>86400</code></td>
</tr>
<tr><td colspan="3">

The age in seconds to continue to make retry attempts.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retry_attempts</td>
    <td><code>185</code></td>
</tr>
<tr><td colspan="3">

The maximum number of retry attempts to make before the request fails

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dead_letter_queue</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ARN of the SQS queue specified as the target for the dead-letter queue.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### schedule_pattern

Define a one-time, or recurring invocation for the schedule. Must define one of: `one_time_schedule`, `rate_based_schedule`, `cron_based_schedule`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">flexible_time_window</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the time window that Scheduler invokes your schedule within, in minutes. For example, if you choose 15 minutes, your schedule runs within 15 minutes after the schedule start time. Valid value: `1` to `1440` minutes

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">time_zone</td>
    <td><code>"UTC"</code></td>
</tr>
<tr><td colspan="3">

Timezone in which the scheduling expression is evaluated. For example: `"America/Los_Angeles"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">start_date_and_time</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The date, in UTC, after which the schedule can begin invoking its target. Depending on the schedule's recurrence expression, invocations might occur on, or after, the start date you specify. EventBridge Scheduler ignores the start date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">end_date_and_time</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The date, in UTC, before which the schedule can invoke its target. Depending on the schedule's recurrence expression, invocations might stop on, or before, the end date you specify. EventBridge Scheduler ignores the end date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#one_time_schedule">one_time_schedule</a>)</code></td>
    <td width="100%">one_time_schedule</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A one-time schedule invokes it's target only once at the date, time, and in the time zone that you provide

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#rate_based_schedule">rate_based_schedule</a>)</code></td>
    <td width="100%">rate_based_schedule</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A rate-based schedule runs at a regular rate, such as every 10 minutes

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#cron_based_schedule">cron_based_schedule</a>)</code></td>
    <td width="100%">cron_based_schedule</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A schedule set using a cron expression that runs at a specific time, such as every day 1 of the month, at 12:00AM.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### schedules

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the schedule

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN for the customer managed KMS key that EventBridge Scheduler will use to encrypt and decrypt your data

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">state</td>
    <td><code>"ENABLED"</code></td>
</tr>
<tr><td colspan="3">

Specifies whether the schedule is enabled or disabled.

**Allowed Values:**

- `ENABLED`
- `DISABLED`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#schedule_pattern">schedule_pattern</a>)</code></td>
    <td width="100%">schedule_pattern</td>
    <td></td>
</tr>
<tr><td colspan="3">

Define a one-time, or recurring invocation for the schedule. Must define one of: `one_time_schedule`, `rate_based_schedule`, `cron_based_schedule`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#target">target</a>)</code></td>
    <td width="100%">target</td>
    <td></td>
</tr>
<tr><td colspan="3">

A target is an AWS API operation that EventBridge Scheduler invokes at the time and using the pattern that you specify when you configure your schedule

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### target

A target is an AWS API operation that EventBridge Scheduler invokes at the time and using the pattern that you specify when you configure your schedule

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">aws_api_action</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS API to invoke. For example: `"lambda:invoke"`, `"ecs:runTask"`. Please refer to [this documentation][eventbridge-scheduler-universal-target] for more details.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">input</td>
    <td></td>
</tr>
<tr><td colspan="3">

A JSON document containing the parameters to pass into the API. The available options depend on the AWS API to invoke, please refer to their respective API reference for valid values. For example: [lambda:invoke][lambda-invoke-api-reference]

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ARN of an IAM role EventBridge Scheduler assumes to send events to the target

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#retry_policy">retry_policy</a>)</code></td>
    <td width="100%">retry_policy</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures retry policy and dead-letter queue

**Since:** 1.0.0

</td></tr>
</tbody></table>

[eventbridge-scheduler-universal-target]: https://docs.aws.amazon.com/scheduler/latest/UserGuide/managing-targets-universal.html?icmpid=docs_console_unmapped
[lambda-invoke-api-reference]: https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html

<!-- TFDOCS_EXTRAS_END -->
