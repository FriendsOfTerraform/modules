# EventBridge Event Bus Module

This module will build and configure an [EventBridge](https://aws.amazon.com/eventbridge/) event bus and rules.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-eventbridge-bus.git?ref=v1.0.0"

  name = "demo-bus"

  # manages multiple rules
  rules = {
    # the key of the map is the rule's name
    test-lambda = {
      event_pattern = jsonencode({
        source      = ["aws.workspaces"]
        detail-type = ["WorkSpaces Access"]
      })

      targets = [
        {
          arn          = "arn:aws:lambda:us-east-1:111122223333:function:psin-test:1"
          iam_role_arn = "arn:aws:iam::111122223333:role/test-event-bus"
        }
      ]
    }

    test-http = {
      event_pattern = jsonencode({
        source      = ["aws.workspaces"]
        detail-type = ["WorkSpaces Access"]
      })

      targets = [
        {
          arn          = "arn:aws:events:us-east-1:111122223333:api-destination/demo-api/abcdef0-1111-2222-87fd-868af648a706"
          iam_role_arn = "arn:aws:iam::111122223333:role/test-event-bus"
        }
      ]
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the event bus

- (map(object)) **`rules`** _[since v1.0.0]_

    Manage multiple rules for the bus. Please [see example](#basic-usage)

    - (string) **`event_pattern`** _[since v1.0.0]_

        Specify the [event pattern][eventbridge-event-pattern] that this rule will be triggered when an event matching the pattern occurs

    - (list(object)) **`targets`** _[since v1.0.0]_

        Specify up to 5 targets to send the event to when the rule is triggered

        - (string) **`arn`** _[since v1.0.0]_

            The Amazon Resource Name (ARN) of the target

        - (object) **`configure_target_input = null`** _[since v1.0.0]_

            Customize the text from an event before EventBridge passes the event to the target of a rule. Can only define only one of the following: `constant`, `input_transformer`. If this is not specified, the original event will be sent to the target

            - (string) **`constant = null`** _[since v1.0.0]_

                The JSON document to be sent to the target instead of the original event

            - (object) **`input_transformer = null`** _[since v1.0.0]_

                Specify how to change some of the event text before passing it to the target. One or more JSON paths are extracted from the event text and used in a template that you provide. Refer to [this documentation][eventbridge-input-transformer] for more information

                - (map(string)) **`input_paths`** _[since v1.0.0]_

                    Key-value pairs that is used to define variables. You use JSON path to reference items in your event and store those values in variables. For instance, you could create an Input Path to reference values in the event.

                - (string) **`template`** _[since v1.0.0]_

                    The Input Template is a template for the information you want to pass to your target. You can create a template that passes either a string or JSON to the target.

        - (string) **`iam_role_arn = null`** _[since v1.0.0]_

            An execution role that EventBridge uses to send events to the target

        - (object) **`ecs_target_config = null`** _[since v1.0.0]_

            Configuration options for ECS target

            - (string) **`task_definition_arn`** _[since v1.0.0]_

                The ARN of the task definition to use to create new ECS task

            - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

                Additional tags for the ECS task

            - (map(object)) **`capacity_provider_strategy = {}`** _[since v1.0.0]_

                The capacity provider strategy to use for the task. Mutually exclusive to `launch_type`

                - (number) **`weight`** _[since v1.0.0]_

                    The weight value designates the relative percentage of the total number of tasks launched that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.

                - (number) **`base = null`** _[since v1.0.0]_

                    The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.

            - (number) **`count = 1`** _[since v1.0.0]_

                The number of tasks to be created

            - (bool) **`enable_execute_command = false`** _[since v1.0.0]_

                Whether or not to enable the execute command functionality for the containers in this task. If true, this enables execute command functionality on all containers in the task.

            - (bool) **`enable_managed_tags = true`** _[since v1.0.0]_

                Specifies whether to enable Amazon ECS managed tags for the task.

            - (string) **`launch_type = null`** _[since v1.0.0]_

                Specifies the launch type on which your task is running. Valid values: `"EC2"`, `"EXTERNAL"`, `"FARGATE"`. Mutually exclusive to `capacity_provider_strategy`

            - (object) **`network_config`** _[since v1.0.0]_

                Configures networking options for the ECS task

                - (list(string)) **`security_group_ids`** _[since v1.0.0]_

                    A list of security groups associated with the task

                - (list(string)) **`subnet_ids`** _[since v1.0.0]_

                    A list of subnets the ECS task may be created on

                - (bool) **`auto_assign_public_ip = false`** _[since v1.0.0]_

                    Assign a public IP address to the ENI (Fargate launch type only).

            - (string) **`platform_version = "LATEST"`** _[since v1.0.0]_

                Specifies the platform version for the task. This is used only if `launch_type = "FARGATE"`. For more information about valid platform versions, see [AWS Fargate Platform Versions][fargate-platform-version].

            - (bool) **`propagate_tags_from_task_definition = false`** _[since v1.0.0]_

                Specifies whether to propagate the tags from the task definition to the task.

        - (object) **`http_target_config = null`** _[since v1.0.0]_

            Configuration options for HTTP and api gateway target

            - (map(string)) **`header_parameters = null`** _[since v1.0.0]_

                A map of HTTP headers to add to the request.

            - (map(string)) **`query_string_parameters = null`** _[since v1.0.0]_

                A map of query string parameters that are appended to the invoked endpoint.

        - (object) **`redshift_target_config = null`** _[since v1.0.0]_

            Configuration options for Redshift target

            - (string) **`database_name`** _[since v1.0.0]_

                The name of the database

            - (string) **`database_user = null`** _[since v1.0.0]_

                The database user name

            - (string) **`secret_manager_arn`** _[since v1.0.0]_

                The ARN of the secret that enables access to the database.

            - (string) **`sql_statement = null`** _[since v1.0.0]_

                The SQL statement text to run.

            - (bool) **`with_event = false`** _[since v1.0.0]_

                Indicates whether to send an event back to EventBridge after the SQL statement runs.

        - (object) **`retry_policy = {}`** _[since v1.0.0]_

            Configures retry policy and dead-letter queue

            - (number) **`maximum_age_of_event = 86400`** _[since v1.0.0]_

                The age in seconds to continue to make retry attempts.

            - (number) **`retry_attempts = 185`** _[since v1.0.0]_

                The maximum number of retry attempts to make before the request fails

            - (string) **`dead_letter_queue = null`** _[since v1.0.0]_

                The ARN of the SQS queue specified as the target for the dead-letter queue.

- (map(object)) **`origins`** _[since v1.0.0]_

    Map of origins for this distribution. Please [see example](#basic-usage)

    - (number) **`connection_attempts = 3`** _[since v1.0.0]_

        The number of times that CloudFront attempts to connect to the origin. Valid values: `1 - 3`

    - (number) **`connection_timeout = 10`** _[since v1.0.0]_

        The number of seconds that CloudFront waits for a response from the origin, from `1 - 10`

    - (map(string)) **`custom_headers = {}`** _[since v1.0.0]_

        Map of headers that CloudFront includes in all requests that it sends to your origin

    - (string) **`origin_path = null`** _[since v1.0.0]_

        Specify a URL path to append to the origin domain name for origin requests

    - (object) **`custom_origin_config = null`** _[since v1.0.0]_

        Configurations for [Cloudfront custom origins][cloudfront-origins]

        - (number) **`http_port = 80`** _[since v1.0.0]_

            Specify the origin's HTTP port

        - (number) **`https_port = 443`** _[since v1.0.0]_

            Specify the origin's HTTPS port

        - (number) **`keep_alive_timeout = 5`** _[since v1.0.0]_

            The number of seconds that CloudFront maintains an idle connection with the origin, from `1 - 60`

        - (string) **`minimum_ssl_protocol = "TLSv1.2"`** _[since v1.0.0]_

            The minimum SSL protocol that CloudFront uses with the origin. Valid values: `"TLSv1.2"`, `"TLSv1.1"`, `"TLSv1"`, `"SSLv3"`

        - (string) **`protocol_policy = "https-only"`** _[since v1.0.0]_

            The origin protocol policy determines the protocol (HTTP or HTTPS) that you want CloudFront to use when connecting to the origin. Valid values: `"http-only"`, `"https-only"`, `"match-viewer"`

        - (number) **`response_timeout = 30`** _[since v1.0.0]_

            The number of seconds that CloudFront waits for a response from the origin, from `1 - 60`

    - (object) **`enable_origin_shield = null`** _[since v1.0.0]_

        [Origin shield][cloudfront-origin-shield] is an additional caching layer that can help reduce the load on your origin and help protect its availability

        - (string) **`region`** _[since v1.0.0]_

            Specify the origin shield region

    - (object) **`s3_origin_config = null`** _[since v1.0.0]_

        Configurations for [S3 origins][cloudfront-origins]

        - (object) **`origin_access`** _[since v1.0.0]_

            You can limit the access to your origin to only authenticated requests from CloudFront. We recommend using origin access control (OAC) in favor of origin access identity (OAI) for its wider range of features, including support of S3 buckets in all AWS Regions.

            - (string) **`origin_access_control_id = null`** _[since v1.0.0]_

                The ID of the origin access control to be associated to this origin. Mutually exclusive to `origin_access_identity`

            - (string) **`origin_access_identity = null`** _[since v1.0.0]_

                The ID of the origin access identity to be associated to this origin. Mutually exclusive to `origin_access_control_id`

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the event bus

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (string) **`description = null`** _[since v1.0.0]_

    The description of the event bus

- (string) **`kms_key_arn = null`** _[since v1.0.0]_

    The AWS KMS customer managed key for EventBridge to use for encryption. If not specified, the AWS default key will be used.

- (string) **`policy = null`** _[since v1.0.0]_

    Specify the JSON document for the event bus' resource-based policy

## Outputs

- (string) **`event_bus_arn`** _[since v1.0.0]_

    ARN of the event bus

- (string) **`event_bus_id`** _[since v1.0.0]_

    Name of the event bus

[eventbridge-event-pattern]:https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html?icmpid=docs_ev_console
[eventbridge-input-transformer]:https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html?icmpid=docs_ev_console
[fargate-platform-version]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-fargate.html
