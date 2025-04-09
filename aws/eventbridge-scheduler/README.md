# EventBridge Scheduler Module

This module will build and configure an [EventBridge](https://aws.amazon.com/eventbridge/) scheduler group and its associated schedules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)

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

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the schedule group

- (map(object)) **`schedules`** _[since v1.0.0]_

    Manage multiple schedules for the group. Please [see example](#basic-usage)

    - (string) **`description = null`** _[since v1.0.0]_

        The description of the schedule

    - (string) **`kms_key_arn = null`** _[since v1.0.0]_

        ARN for the customer managed KMS key that EventBridge Scheduler will use to encrypt and decrypt your data

    - (string) **`state = "ENABLED"`** _[since v1.0.0]_

        Specifies whether the schedule is enabled or disabled. Valid values: `"ENABLED"`, `"DISABLED"`

    - (object) **`schedule_pattern`** _[since v1.0.0]_

        Define a one-time, or recurring invocation for the schedule. Must define one of: `one_time_schedule`, `rate_based_schedule`, `cron_based_schedule`

        - (number) **`flexible_time_window = null`** _[since v1.0.0]_

            Specify the time window that Scheduler invokes your schedule within, in minutes. For example, if you choose 15 minutes, your schedule runs within 15 minutes after the schedule start time. Valid value: `1` to `1440` minutes

        - (string) **`time_zone = "UTC`** _[since v1.0.0]_

            Timezone in which the scheduling expression is evaluated. For example: `"America/Los_Angeles"`

        - (string) **`start_date_and_time = null`** _[since v1.0.0]_

            The date, in UTC, after which the schedule can begin invoking its target. Depending on the schedule's recurrence expression, invocations might occur on, or after, the start date you specify. EventBridge Scheduler ignores the start date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`

        - (string) **`end_date_and_time = null`** _[since v1.0.0]_

            The date, in UTC, before which the schedule can invoke its target. Depending on the schedule's recurrence expression, invocations might stop on, or before, the end date you specify. EventBridge Scheduler ignores the end date for one-time schedules. Example: `"2030-01-01T01:00:00Z"`

        - (object) **`one_time_schedule = null`** _[since v1.0.0]_

            A one-time schedule invokes it's target only once at the date, time, and in the time zone that you provide

            - (string) **`date_and_time = null`** _[since v1.0.0]_

                The date and time this schedule run, in `yyyy-mm-ddThh:mm:ss` format. For example: `"2030-01-01T01:00:00"`

        - (object) **`rate_based_schedule = null`** _[since v1.0.0]_

            A rate-based schedule runs at a regular rate, such as every 10 minutes

            - (string) **`rate_expression`** _[since v1.0.0]_

                The rate to invoke this trigger, in `value unit` format. For example: `"1 hour"`

        - (object) **`cron_based_schedule = null`** _[since v1.0.0]_

            A schedule set using a cron expression that runs at a specific time, such as every day 1 of the month, at 12:00AM.

            - (string) **`cron_expression`** _[since v1.0.0]_

                Specify the cron expression for the schedule, for example: `"0 0 1 * *"`

        - (object) **`target`** _[since v1.0.0]_

            A target is an AWS API operation that EventBridge Scheduler invokes at the time and using the pattern that you specify when you configure your schedule

            - (string) **`aws_api_action`** _[since v1.0.0]_

                The AWS API to invoke. For example: `"lambda:invoke"`, `"ecs:runTask"`. Please refer to [this documentation][eventbridge-scheduler-universal-target] for more details.

            - (string) **`input`** _[since v1.0.0]_

                A JSON document containing the parameters to pass into the API. The available options depend on the AWS API to invoke, please refer to their respective API reference for valid values. For example: [lambda:invoke][lambda-invoke-api-reference]

            - (string) **`iam_role_arn = null`** _[since v1.0.0]_

                The ARN of an IAM role EventBridge Scheduler assumes to send events to the target

            - (object) **`retry_policy = {}`** _[since v1.0.0]_

                Configures retry policy and dead-letter queue

                - (number) **`maximum_age_of_event = 86400`** _[since v1.0.0]_

                    The age in seconds to continue to make retry attempts.

                - (number) **`retry_attempts = 185`** _[since v1.0.0]_

                    The maximum number of retry attempts to make before the request fails

                - (string) **`dead_letter_queue = null`** _[since v1.0.0]_

                    The ARN of the SQS queue specified as the target for the dead-letter queue.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the schedule group

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

[eventbridge-scheduler-universal-target]:https://docs.aws.amazon.com/scheduler/latest/UserGuide/managing-targets-universal.html?icmpid=docs_console_unmapped
[lambda-invoke-api-reference]:https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html
