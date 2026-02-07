variable "name" {
  type        = string
  description = <<EOT
    The name of the event bus

    @since 1.0.0
  EOT
}

variable "rules" {
  type = map(object({
    /// Specify the [event pattern][eventbridge-event-pattern] that this rule will be triggered when an event matching the pattern occurs
    ///
    /// @link {eventbridge-event-pattern} https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html?icmpid=docs_ev_console
    /// @since 1.0.0
    event_pattern   = string
    additional_tags = optional(map(string), {})
    description     = optional(string, null)
    state           = optional(string, "ENABLED")

    # APIGATEWAY, CLOUDWATCH_LOG_GROUP, ECS, EVENTBUS, FIREHOSE, HTTP, LAMBDA, REDSHIFT, SNS, SQS, STEPFUNCTION,
    /// Specify up to 5 targets to send the event to when the rule is triggered
    ///
    /// @since 1.0.0
    targets = list(object({
      /// The Amazon Resource Name (ARN) of the target
      ///
      /// @since 1.0.0
      arn          = string
      /// An execution role that EventBridge uses to send events to the target
      ///
      /// @since 1.0.0
      iam_role_arn = optional(string, null)

      /// Customize the text from an event before EventBridge passes the event to the target of a rule. Can only define only one of the following: `constant`, `input_transformer`. If this is not specified, the original event will be sent to the target
      ///
      /// @since 1.0.0
      configure_target_input = optional(object({
        /// The JSON document to be sent to the target instead of the original event
        ///
        /// @since 1.0.0
        constant = optional(string, null)
        /// Specify how to change some of the event text before passing it to the target. One or more JSON paths are extracted from the event text and used in a template that you provide. Refer to [this documentation][eventbridge-input-transformer] for more information
        ///
        /// @link {eventbridge-input-transformer} https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html?icmpid=docs_ev_console
        /// @since 1.0.0
        input_transformer = optional(object({
          /// Key-value pairs that is used to define variables. You use JSON path to reference items in your event and store those values in variables. For instance, you could create an Input Path to reference values in the event.
          ///
          /// @since 1.0.0
          input_paths = map(string)
          /// The Input Template is a template for the information you want to pass to your target. You can create a template that passes either a string or JSON to the target.
          ///
          /// @since 1.0.0
          template    = string
        }), null)
      }))

      # TODO: task_group, placement_constraint, placement_strategy
      /// Configuration options for ECS target
      ///
      /// @since 1.0.0
      ecs_target_config = optional(object({
        /// The ARN of the task definition to use to create new ECS task
        ///
        /// @since 1.0.0
        task_definition_arn = string

        /// Configures networking options for the ECS task
        ///
        /// @since 1.0.0
        network_config = object({
          /// A list of subnets the ECS task may be created on
          ///
          /// @since 1.0.0
          subnet_ids            = list(string)
          /// A list of security groups associated with the task
          ///
          /// @since 1.0.0
          security_group_ids    = list(string)
          /// Assign a public IP address to the ENI (Fargate launch type only).
          ///
          /// @since 1.0.0
          auto_assign_public_ip = optional(bool, false)
        })

        /// Additional tags for the ECS task
        ///
        /// @since 1.0.0
        additional_tags                     = optional(map(string), {})
        /// The number of tasks to be created
        ///
        /// @since 1.0.0
        count                               = optional(number, 1)
        /// Whether or not to enable the execute command functionality for the containers in this task. If true, this enables execute command functionality on all containers in the task.
        ///
        /// @since 1.0.0
        enable_execute_command              = optional(bool, false)
        /// Specifies whether to enable Amazon ECS managed tags for the task.
        ///
        /// @since 1.0.0
        enable_managed_tags                 = optional(bool, true)
        /// Specifies the launch type on which your task is running. Mutually exclusive to `capacity_provider_strategy`
        ///
        /// @enum EC2|EXTERNAL|FARGATE
        /// @since 1.0.0
        launch_type                         = optional(string, null)
        /// Specifies the platform version for the task. This is used only if `launch_type = "FARGATE"`. For more information about valid platform versions, see [AWS Fargate Platform Versions][fargate-platform-version].
        ///
        /// @link {fargate-platform-version} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-fargate.html
        /// @since 1.0.0
        platform_version                    = optional(string, "LATEST")
        /// Specifies whether to propagate the tags from the task definition to the task.
        ///
        /// @since 1.0.0
        propagate_tags_from_task_definition = optional(bool, false)

        /// The capacity provider strategy to use for the task. Mutually exclusive to `launch_type`
        ///
        /// @since 1.0.0
        capacity_provider_strategy = optional(map(object({
          /// The weight value designates the relative percentage of the total number of tasks launched that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.
          ///
          /// @since 1.0.0
          weight = number
          /// The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
          ///
          /// @since 1.0.0
          base   = optional(number, null)
        })), {})
      }), null)

      /// Configuration options for HTTP and api gateway target
      ///
      /// @since 1.0.0
      http_target_config = optional(object({
        /// A map of HTTP headers to add to the request.
        ///
        /// @since 1.0.0
        header_parameters       = optional(map(string), null)
        /// A map of query string parameters that are appended to the invoked endpoint.
        ///
        /// @since 1.0.0
        query_string_parameters = optional(map(string), null)
      }), null)

      /// Configuration options for Redshift target
      ///
      /// @since 1.0.0
      redshift_target_config = optional(object({
        /// The name of the database
        ///
        /// @since 1.0.0
        database_name      = string
        /// The database user name
        ///
        /// @since 1.0.0
        database_user      = optional(string, null)
        /// The ARN of the secret that enables access to the database.
        ///
        /// @since 1.0.0
        secret_manager_arn = optional(string, null)
        /// The SQL statement text to run.
        ///
        /// @since 1.0.0
        sql_statement      = optional(string, null)
        /// Indicates whether to send an event back to EventBridge after the SQL statement runs.
        ///
        /// @since 1.0.0
        with_event         = optional(bool, false)
      }), null)

      /// Configures retry policy and dead-letter queue
      ///
      /// @since 1.0.0
      retry_policy = optional(object({
        /// The age in seconds to continue to make retry attempts.
        ///
        /// @since 1.0.0
        maximum_age_of_event = optional(number, 86400)
        /// The maximum number of retry attempts to make before the request fails
        ///
        /// @since 1.0.0
        retry_attempts       = optional(number, 185)
        /// The ARN of the SQS queue specified as the target for the dead-letter queue.
        ///
        /// @since 1.0.0
        dead_letter_queue    = optional(string, null)
      }), {})
    }))
  }))
  description = <<EOT
    Manage multiple rules for the bus.

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the event bus

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "description" {
  type        = string
  description = <<EOT
    The description of the event bus

    @since 1.0.0
  EOT
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = <<EOT
    The AWS KMS customer managed key for EventBridge to use for encryption. If not specified, the AWS default key will be used.

    @since 1.0.0
  EOT
  default     = null
}

variable "policy" {
  type        = string
  description = <<EOT
    Specify the JSON document for the event bus' resource-based policy

    @since 1.0.0
  EOT
  default     = null
}
