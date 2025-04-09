variable "name" {
  type        = string
  description = "The name of the event bus. All associated resources' names will also be prefixed by this value"
}

variable "rules" {
  type = map(object({
    event_pattern   = string
    additional_tags = optional(map(string), {})
    description     = optional(string, null)
    state           = optional(string, "ENABLED")

    # APIGATEWAY, CLOUDWATCH_LOG_GROUP, ECS, EVENTBUS, FIREHOSE, HTTP, LAMBDA, REDSHIFT, SNS, SQS, STEPFUNCTION,
    targets = list(object({
      arn          = string
      iam_role_arn = optional(string, null)

      configure_target_input = optional(object({
        constant = optional(string, null)
        input_transformer = optional(object({
          input_paths = map(string)
          template    = string
        }), null)
      }))

      # TODO: task_group, placement_constraint, placement_strategy
      ecs_target_config = optional(object({
        task_definition_arn = string

        network_config = object({
          subnet_ids            = list(string)
          security_group_ids    = list(string)
          auto_assign_public_ip = optional(bool, false)
        })

        additional_tags                     = optional(map(string), {})
        count                               = optional(number, 1)
        enable_execute_command              = optional(bool, false)
        enable_managed_tags                 = optional(bool, true)
        launch_type                         = optional(string, null)
        platform_version                    = optional(string, "LATEST")
        propagate_tags_from_task_definition = optional(bool, false)

        capacity_provider_strategy = optional(map(object({
          weight = number
          base   = optional(number, null)
        })), {})
      }), null)

      http_target_config = optional(object({
        header_parameters       = optional(map(string), null)
        query_string_parameters = optional(map(string), null)
      }), null)

      redshift_target_config = optional(object({
        database_name      = string
        database_user      = optional(string, null)
        secret_manager_arn = optional(string, null)
        sql_statement      = optional(string, null)
        with_event         = optional(bool, false)
      }), null)

      retry_policy = optional(object({
        maximum_age_of_event = optional(number, 86400)
        retry_attempts       = optional(number, 185)
        dead_letter_queue    = optional(string, null)
      }), {})
    }))
  }))
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the event bus"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "description" {
  type        = string
  description = "The description of the event bus"
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = ""
  default     = null
}

variable "policy" {
  type        = string
  description = ""
  default     = null
}
