variable "code_source" {
  type = object({
    container_image_uri = optional(string)
    /// Path to the function's deployment package within the local filesystem
    /// 
    /// @since 1.0.0
    filename            = optional(string)

    /// S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region where you are creating the Lambda function
    /// 
    /// @since 1.0.0
    s3 = optional(object({
      /// Specify the S3 URI of the deployment package to use for this function. [See example](#basic-usage)
      /// 
      /// @since 1.0.0
      uri     = string # s3://bucket/prefix
      /// Object version containing the function's deployment package
      /// 
      /// @since 1.0.0
      version = optional(string)
    }))
  })
  description = <<EOT
    Specify the code source. Exactly one of `container_image_uri`, `filename`, or `s3` must be specified
    
    @since 1.0.0
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the Lambda function. All associated resources' names will also be prefixed by this value
    
    @since 1.0.0
  EOT
}

variable "additional_execution_role_policies" {
  type        = list(string)
  description = <<EOT
    Additional IAM policies to be attached to the managed execution IAM role. This is ignored if `execution_role_arn` is specified
    
    @since 1.0.0
  EOT
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the Lambda function
    
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

variable "aliases" {
  type = map(object({
    /// Lambda function version for which you are creating the alias
    /// 
    /// @since 1.0.0
    function_version = string
    /// Description of the alias
    /// 
    /// @since 1.0.0
    description      = optional(string)

    /// Confiugres this alias to send a portion of traffic to a second function version. Used for canary deployment scenarios. Please refer to [this documentation][lambda-alias-routing] for a list of requirements for this feature.
    /// 
    /// @since 1.0.0
    weighted_alias = optional(object({
      /// The second function version to route portion of the traffic to
      /// 
      /// @since 1.0.0
      function_version = string
      /// The weight, in percentage, of the total traffic routed to the second function version
      /// 
      /// @since 1.0.0
      weight           = number
    }))
  }))
  description = <<EOT
    Manages multiple Lambda aliases. [See example](#versioning-and-aliases)
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "architecture" {
  type        = string
  description = <<EOT
    Specify the instruction set architecture for this Lambda function. Valid values are `"x86_64"`, `"arm64"`
    
    @since 1.0.0
  EOT
  default     = "x86_64"
}

variable "asynchronous_invocation" {
  type = object({
    /// Specify the ARN of the destination for failed asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].
    /// 
    /// @since 1.0.0
    on_failure_destination_arn = optional(string)
    /// Specify the ARN of the destination for successful asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].
    /// 
    /// @since 1.0.0
    on_success_destination_arn = optional(string)

    /// Configures error handlings
    /// 
    /// @since 1.0.0
    retries = optional(object({
      /// The maximum amount of time Lambda retains an event in the asynchronous event queue, up to 6 hours
      /// 
      /// @since 1.0.0
      maximum_event_age_in_seconds = optional(number, 21600) # 6 hours
      /// The number of times Lambda retries when the function returns an error, between 0 and 2
      /// 
      /// @since 1.0.0
      maximum_retry_attempts       = optional(number, 2)
    }))
  })
  description = <<EOT
    Configures error handling and destinations for [asynchronous invocation][lambda-asynchronous-invocation]. [See example](#asynchronous-invocation-configuration)
    
    @since 1.0.0
  EOT
  default     = null
}

variable "container_image_overrides" {
  type = object({
    /// Specifies parameters that you want to pass in with ENTRYPOINT
    /// 
    /// @since 1.0.0
    cmd        = optional(string)
    /// Specifies the absolute path to the entry point of the application
    /// 
    /// @since 1.0.0
    entrypoint = optional(string)
    /// Specifies the absolute path to the working directory
    /// 
    /// @since 1.0.0
    workdir    = optional(string)
  })
  description = <<EOT
    Container image configuration values that override the values in the container image Dockerfile. Only applicable if `code_source.container_image_uri` is specified
    
    @since 1.0.0
  EOT
  default     = null
}

variable "concurrency" {
  type = object({
    /// Specify the maximum number of concurrent instances allocated to the function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations
    /// 
    /// @since 1.0.0
    reserved_concurrency      = optional(number, -1)
    /// Map of provisioned concurrencies assigned to Lambda qualifiers. [See example](#provisioned-concurrency)
    /// 
    /// @since 1.0.0
    provisioned_concurrencies = optional(map(number), {})
  })
  description = <<EOT
    Configures [Lambda concurrency][lambda-concurrency]
    
    @since 1.0.0
  EOT
  default     = null
}

variable "description" {
  type        = string
  description = <<EOT
    The description for this Lambda function
    
    @since 1.0.0
  EOT
  default     = null
}

variable "enable_active_tracing" {
  type = object({
    /// Specifies the tracing mode. Valid values are: `"PassThrough"`, `"Active"`. If `"PassThrough"`, Lambda will only trace the request from an upstream service if it contains a tracing header with `"sampled=1"`. If `"Active"`, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision
    /// 
    /// @since 1.0.0
    mode = optional(string, "Active")
  })
  description = <<EOT
    Enables Lambda [active tracing with AWS X-Ray][lambda-active-tracing]
    
    @since 1.0.0
  EOT
  default     = null
}

variable "enable_function_url" {
  type = object({
    /// The type of authentication that the function URL uses. Valid values: `"AWS_IAM"`, `"NONE"` Set to `"AWS_IAM"` to restrict access to authenticated IAM users only. Set to `"NONE"` to bypass IAM authentication and create a public endpoint.
    /// 
    /// @since 1.0.0
    auth_type   = optional(string, "AWS_IAM")
    /// Determines how the Lambda function responds to an invocation. Valid values are: `"BUFFERED"`, `"RESPONSE_STREAM"`
    /// 
    /// @since 1.0.0
    invoke_mode = optional(string, "BUFFERED")

    /// Configures the cross-origin resource sharing (CORS) settings for the function URL
    /// 
    /// @since 1.0.0
    cors_config = optional(object({
      /// Whether to allow cookies or other credentials in requests to the function URL
      /// 
      /// @since 1.0.0
      allow_credentials = optional(bool, false)
      /// The HTTP headers that origins can include in requests to the function URL. For example: `["date", "keep-alive", "x-custom-header"]`
      /// 
      /// @since 1.0.0
      allow_headers     = optional(list(string))
      /// The HTTP methods that are allowed when calling the function URL. For example: `["GET", "POST", "DELETE"]`
      /// 
      /// @since 1.0.0
      allow_methods     = optional(list(string), ["*"])
      /// The origins that can access the function URL. For example: `["https://www.example.com", "http://localhost:60905"]`
      /// 
      /// @since 1.0.0
      allow_origins     = optional(list(string), ["*"])
      /// The HTTP headers in your function response that you want to expose to origins that call the function URL
      /// 
      /// @since 1.0.0
      expose_headers    = optional(list(string))
      /// The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. Valid values: `0 - 86400`
      /// 
      /// @since 1.0.0
      max_age_seconds   = optional(number, 0)
    }))
  })
  description = <<EOT
    Enables [Lambda function URL][lambda-function-url], a dedicated HTTP(S) endpoint for the function
    
    @since 1.0.0
  EOT
  default     = null
}

variable "environment_variables" {
  type = object({
    /// A map of environment variables to pass to the function
    /// 
    /// @since 1.0.0
    variables   = map(string)
    /// Specify the ARN of the KMS key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key
    /// 
    /// @since 1.0.0
    kms_key_arn = optional(string)
  })
  description = <<EOT
    Configures environment variables for the function
    
    @since 1.0.0
  EOT
  default     = null
}

variable "ephemeral_storage" {
  type        = number
  description = <<EOT
    The size of the Lambda function Ephemeral storage(/tmp) in MB. Valid values: `512 - 10240`
    
    @since 1.0.0
  EOT
  default     = 512
}

variable "execution_role_arn" {
  type        = string
  description = <<EOT
    Specify the ARN of the function's execution role. The role provides the function's identity and access to AWS services and resources. If not specified, a role will be generated and managed automatically by the module.
    
    @since 1.0.0
  EOT
  default     = null
}

variable "file_system_config" {
  type = object({
    /// ARN of the Amazon EFS Access Point that provides access to the file system
    /// 
    /// @since 1.0.0
    access_point_arn = string
    /// Path where the function can access the file system, Must starts with `"/mnt/"`
    /// 
    /// @since 1.0.0
    local_mount_path = string
  })
  description = <<EOT
    Connects the function to an EFS file system
    
    @since 1.0.0
  EOT
  default     = null
}

variable "handler" {
  type        = string
  description = <<EOT
    Specify the function entrypoint in your code
    
    @since 1.0.0
  EOT
  default     = null
}

variable "lambda_permissions" {
  type = map(object({
    /// The external source this policy is configured for. Valid values: `"aws_account"`, `"aws_service"`, `"function_url"`
    /// 
    /// @since 1.0.0
    policy_type               = string # aws_account, aws_service, function_url
    /// Specify the principal who is getting this permission. If `policy_type = "aws_service"`, you must specify an AWS service URL such as `"s3.amazonaws.com"`. Otherwise, you can specify an AWS account ID such as `"111122223333"` or an IAM user ARN.
    /// 
    /// @since 1.0.0
    principal                 = string # service principal, arn of account, user, or role
    /// The AWS Lambda action you want to allow in this statement. Defaults to `"lambda:InvokeFunctionUrl"` if `policy_type = "function_url"`, and `"lambda:InvokeFunction"` otherwise.
    /// 
    /// @since 1.0.0
    action                    = optional(string)
    /// The Event Source Token to validate. Valid only with an Alexa Skill principal.
    /// 
    /// @since 1.0.0
    event_source_token        = optional(string)
    /// Lambda Function URLs authentication type. Valid values: `"AWS_IAM"`, `"NONE"`. Only supported for `policy_type = "function_url"` and `action = "lambda:InvokeFunctionUrl"`
    /// 
    /// @since 1.0.0
    function_url_auth_type    = optional(string)
    /// The ID of an organization in AWS Organizations. Use this to grant permissions to only the AWS accounts under this organization.
    /// 
    /// @since 1.0.0
    principal_organization_id = optional(string)
    /// The AWS account ID of the source owner. Used to grant permissions to an AWS service outside of this function's account, such as an S3 bucket. Only valid if `policy_type = "aws_service"`
    /// 
    /// @since 1.0.0
    source_account_id         = optional(string)
    /// The ARN of the specific resource within that service to grant permission to, such as an S3 bucket ARN. Only valid if `policy_type = "aws_service"`
    /// 
    /// @since 1.0.0
    source_arn                = optional(string)
  }))
  description = <<EOT
    Grants external sources such as AWS accounts and services permission to invoke the Lambda function. [See example](#lambda-permission)
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "layer_arns" {
  type        = list(string)
  description = <<EOT
    List of [Lambda Layer][lambda-layer] Version ARNs (maximum of 5) to attach to your Lambda Function
    
    @since 1.0.0
  EOT
  default     = []
}

variable "memory" {
  type        = number
  description = <<EOT
    Amount of memory in MB your Lambda Function can use at runtime. Valid values: `128 - 10240`
    
    @since 1.0.0
  EOT
  default     = 128
}

variable "publish_as_new_version" {
  type        = bool
  description = <<EOT
    Whether to publish creation/change as new Lambda Function Version
    
    @since 1.0.0
  EOT
  default     = false
}

variable "runtime" {
  type        = string
  description = <<EOT
    Specify the language runtime. Please refer to [this documentation][lambda-runtime] for a list of valid values.
    
    @since 1.0.0
  EOT
  default     = null
}

variable "source_code_hash" {
  type        = string
  description = <<EOT
    Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the deployment package file. The usual way to set this is `filebase64sha256("source.zip")`. Only applicable if `code_source.filename` or `code_source.s3` is specified
    
    @since 1.0.0
  EOT
  default     = null
}

variable "timeout" {
  type        = number
  description = <<EOT
    Specify timeout in seconds for the function, up to `900`
    
    @since 1.0.0
  EOT
  default     = 3
}

variable "vpc_config" {
  type = object({
    /// List of security group IDs associated with the ENIs of the Lambda function
    /// 
    /// @since 1.0.0
    security_group_ids = list(string)
    /// List of subnet IDs associated with the ENIs of the Lambda function
    /// 
    /// @since 1.0.0
    subnet_ids         = list(string)
    /// Allows outbound IPv6 traffic on VPC functions that are connected to dual-stack subnets
    /// 
    /// @since 1.0.0
    enable_dual_stack  = optional(bool, false)
  })
  description = <<EOT
    Configure this function to [connect to private subnets in a VPC][lambda-vpc-config], allowing it access to private resources. The required IAM policy will be automatically attached to the managed role if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided has the IAM policy `AWSLambdaENIManagementAccess` attached.
    
    @since 1.0.0
  EOT
  default     = null
}
