variable "code_source" {
  type = object({
    container_image_uri = optional(string)
    filename            = optional(string)

    s3 = optional(object({
      uri     = string # s3://bucket/prefix
      version = optional(string)
    }))
  })
  description = "Specify the code source"
}

variable "name" {
  type        = string
  description = "The name of the lambda function. All associated resources' names will also be prefixed by this value"
}

variable "additional_execution_role_policies" {
  type        = list(string)
  description = "Additional IAM policies to be attached to the managed execution IAM role."
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the lambda function"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "aliases" {
  type = map(object({
    function_version = string
    description      = optional(string)

    weighted_alias = optional(object({
      function_version = string
      weight           = number
    }))
  }))
  description = "Manages multiple Lambda aliases"
  default     = {}
}

variable "architecture" {
  type        = string
  description = "Specify the instruction set architecture for the function code"
  default     = "x86_64"
}

variable "asynchronous_invocation" {
  type = object({
    on_failure_destination_arn = optional(string)
    on_success_destination_arn = optional(string)

    retries = optional(object({
      maximum_event_age_in_seconds = optional(number, 21600) # 6 hours
      maximum_retry_attempts       = optional(number, 2)
    }))
  })
  description = "Configures error handling and destinations for asynchronous invocation"
  default     = null
}

variable "container_image_overrides" {
  type = object({
    cmd        = optional(string)
    entrypoint = optional(string)
    workdir    = optional(string)
  })
  description = "Container image configuration values that override the values in the container image Dockerfile"
  default     = null
}

variable "concurrency" {
  type = object({
    reserved_concurrency      = optional(number, -1)
    provisioned_concurrencies = optional(map(number), {})
  })
  description = "Configures Lambda concurrency"
  default     = null
}

variable "description" {
  type        = string
  description = "Specify the description of the lambda function"
  default     = null
}

variable "enable_active_tracing" {
  type = object({
    mode = optional(string, "Active")
  })
  description = "Enables Lambda active tracing with AWS X-Ray"
  default     = null
}

variable "enable_function_url" {
  type = object({
    auth_type   = optional(string, "AWS_IAM")
    invoke_mode = optional(string, "BUFFERED")

    cors_config = optional(object({
      allow_credentials = optional(bool, false)
      allow_headers     = optional(list(string))
      allow_methods     = optional(list(string), ["*"])
      allow_origins     = optional(list(string), ["*"])
      expose_headers    = optional(list(string))
      max_age_seconds   = optional(number, 0)
    }))
  })
  description = "Enables Lambda function URL endpoint"
  default     = null
}

variable "environment_variables" {
  type = object({
    variables   = map(string)
    kms_key_arn = optional(string)
  })
  description = "Configure environment variables for the function"
  default     = null
}

variable "ephemeral_storage" {
  type        = number
  description = "Specify ephemeral storage (/tmp) size in MB for the function runtime"
  default     = 512
}

variable "execution_role_arn" {
  type        = string
  description = "Specify the ARN of the function's execution role"
  default     = null
}

variable "file_system_config" {
  type = object({
    access_point_arn = string
    local_mount_path = string
  })
  description = "Connection settings for an EFS file system"
  default     = null
}

variable "handler" {
  type        = string
  description = "Specify the function entrypoint in your code"
  default     = null
}

variable "lambda_permissions" {
  type = map(object({
    policy_type               = string # aws_account, aws_service, function_url
    principal                 = string # service principal, arn of account, user, or role
    action                    = optional(string)
    event_source_token        = optional(string)
    function_url_auth_type    = optional(string)
    principal_organization_id = optional(string)
    source_account_id         = optional(string)
    source_arn                = optional(string)
  }))
  description = "Gives an external source such as AWS accounts and services permission to invoke the Lambda function"
  default     = {}
}

variable "layer_arns" {
  type        = list(string)
  description = "List of Lambda layer ARNs. Up to 5"
  default     = []
}

variable "memory" {
  type        = number
  description = "Specify memory in MB for the function runtime"
  default     = 128
}

variable "publish_as_new_version" {
  type        = bool
  description = "Whether to publish creation/change as new Lambda Function Version"
  default     = false
}

variable "runtime" {
  type        = string
  description = "Specify the language runtime"
  default     = null
}

variable "source_code_hash" {
  type        = string
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the deployment package file"
  default     = null
}

variable "timeout" {
  type        = number
  description = "Specify timeout in seconds for the function"
  default     = 3
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
    enable_dual_stack  = optional(bool, false)
  })
  description = "Configures options to allow the function network connectivity to AWS resources in a VPC"
  default     = null
}
