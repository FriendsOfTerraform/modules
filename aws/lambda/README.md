# Lambda Module

This module will build and configure a [Lambda](https://aws.amazon.com/lambda/) function

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Asynchronous Invocation Configuration](#asynchronous-invocation-configuration)
    - [Enhanced Monitoring](#enhanced-monitoring)
    - [Lambda Permission](#lambda-permission)
    - [Provisioned Concurrency](#provisioned-concurrency)
    - [Versioning and Aliases](#versioning-and-aliases)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "lambda_basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name    = "lambda-demo"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source.zip"
    }
  }

  environment_variables = {
    variables = {
      "VAR_1" = "VALUE_1"
      "VAR_2" = "VALUE_2"
    }
  }
}
```

### Asynchronous Invocation Configuration

```terraform
module "lambda_basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name    = "lambda-demo"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source.zip"
    }
  }

  asynchronous_invocation = {
    # Records of failed asynchronous invocations will be sent to the "failed-topic" SNS topic
    on_failure_destination_arn = "arn:aws:sns:us-east-1:111122223333:failed-topic"

    # Records of succeed asynchronous invocations will be sent to the "success-topic" SNS topic
    on_success_destination_arn = "arn:aws:sns:us-east-1:111122223333:success-topic"
  }
}
```

### Enhanced Monitoring

The following example demonstrates how to enable [Lambda enhanced monitoring][lambda-enhanced-monitoring]. This feature requires the LambdaInsightsExtension, you can get a list of available versions [from here][lambda-insight-extension-versions].

```terraform
module "lambda_enhanced_monitoring" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name    = "lambda-demo"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source.zip"
    }
  }

  # enhanced monitoring requires additional IAM permission
  additional_execution_role_policies = [ "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy" ]

  # enhanced monitoring also requires the following Lambda layer to be attached
  layer_arns = [ "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:38" ]
}
```

### Lambda Permission

```terraform
module "lambda_permission" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name    = "lambda-demo"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source.zip"
    }
  }

  # Configures multiple Lambda permissions
  lambda_permissions = {
    # The keys of the map will be the Statement ID
    # Allow an S3 bucket (demo-bucket) to invoke this Lambda function
    "Allow_S3_demo-bucket" = {
      policy_type = "aws_service"
      principal   = "s3.amazonaws.com"
      source_arn  = "arn:aws:s3:::demo-bucket"
    }

    # Allow all principals from an AWS account (111122223333) to invoke this Lambda function via the function URL
    "Allow_account_111122223333_to_call_function_url" = {
      policy_type = "function_url"
      principal   = "111122223333"
    }

    # Allow all principals within an AWS organization (o-a1b2c3d4e5f) to invoke this Lambda function
    "Allow_all_aws_accounts_from_organization_o-a1b2c3d4e5f" = {
      policy_type               = "aws_account"
      principal                 = "*"
      principal_organization_id = "o-a1b2c3d4e5f"
    }

    # Allow a single user to invoke this Lambda function
    "Allow_aws_account_psin" = {
      policy_type = "aws_account"
      principal   = "arn:aws:iam::111122223333:user/psin"
    }
  }
}
```

### Provisioned Concurrency

```terraform
module "lambda_provisioned_concurrency" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name                   = "lambda-demo"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  publish_as_new_version = true

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source_v2.zip"
    }
  }

  aliases = {
    "staging" = {
      function_version = "2"
    }
  }

  concurrency = {
    provisioned_concurrencies = {
      # The key of the map is the qualifier of the function to provision concurrency
      # It can be a function version or an alias

      "3"       = 100 # provisioning 100 concurreny units to function version 3
      "staging" = 10  # provisioning 10 concurreny units to alias staging
    }
  }
}
```

### Versioning and Aliases

```terraform
module "lambda_versioning" {
  source = "github.com/FriendsOfTerraform/aws-lambda.git?ref=v1.0.0"

  name    = "lambda-demo"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  code_source = {
    s3 = {
      uri = "s3://lambda-code-bucket/demo-application/source_v2.zip"
    }
  }

  # This will create a new Lambda version
  publish_as_new_version = true

  aliases = {
    # The keys of the map will be the alias' name
    "staging" = {
      function_version = "2"
    }
    "canary-release-v3" = {
      function_version = "2"
      description      = "Canary deployment to V3, monitor for 24 hours"

      weighted_alias = {
        function_version = "3"
        weight           = 20 # routes 20% of total traffics to v3
      }
    }
  }
}
```

## Argument Reference

### Mandatory

- (object) **`code_source`** _[since v1.0.0]_

    Specify the code source. Exactly one of `container_image_uri`, `filename`, or `s3` must be specified

    - (string) **`container_image_url = null`** _[since v1.0.0]_

        Specify the Amazon ECR image URI of the container image to use for this function

    - (string) **`filename = null`** _[since v1.0.0]_

        Path to the function's deployment package within the local filesystem

    - (object) **`s3 = null`** _[since v1.0.0]_

        S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region where you are creating the Lambda function

        - (string) **`uri`** _[since v1.0.0]_

            Specify the S3 URI of the deployment package to use for this function. [See example](#basic-usage)

        - (string) **`version = null`** _[since v1.0.0]_

            Object version containing the function's deployment package

- (string) **`name`** _[since v1.0.0]_

    The name of the Lambda function. All associated resources' names will also be prefixed by this value

### Optional

- (list(string)) **`additional_execution_role_policies = []`** _[since v1.0.0]_

    Additional IAM policies to be attached to the managed execution IAM role. This is ignored if `execution_role_arn` is specified

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the Lambda function

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`aliases = {}`** _[since v1.0.0]_

    Manages multiple Lambda aliases. [See example](#versioning-and-aliases)

    - (string) **`function_version`** _[since v1.0.0]_

        Lambda function version for which you are creating the alias

    - (string) **`description = null`** _[since v1.0.0]_

        Description of the alias

    - (object) **`weighted_alias = null`** _[since v1.0.0]_

        Confiugres this alias to send a portion of traffic to a second function version. Used for canary deployment scenarios. Please refer to [this documentation][lambda-alias-routing] for a list of requirements for this feature.

        - (string) **`function_version`** _[since v1.0.0]_

            The second function version to route portion of the traffic to

        - (number) **`weight`** _[since v1.0.0]_

            The weight, in percentage, of the total traffic routed to the second function version

- (string) **`architecture = "x86_64"`** _[since v1.0.0]_

    Specify the instruction set architecture for this Lambda function. Valid values are `"x86_64"`, `"arm64"`

- (object) **`asynchronous_invocation = null`** _[since v1.0.0]_

    Configures error handling and destinations for [asynchronous invocation][lambda-asynchronous-invocation]. [See example](#asynchronous-invocation-configuration)

    - (string) **`on_failure_destination_arn = null`** _[since v1.0.0]_

        Specify the ARN of the destination for failed asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].

    - (string) **`on_success_destination_arn = null`** _[since v1.0.0]_

        Specify the ARN of the destination for successful asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].

    - (object) **`retries = null`** _[since v1.0.0]_

        Configures error handlings

        - (number) **`maximum_event_age_in_seconds = 21600`** _[since v1.0.0]_

            The maximum amount of time Lambda retains an event in the asynchronous event queue, up to 6 hours

        - (number) **`maximum_retry_attempts = 2`** _[since v1.0.0]_

            The number of times Lambda retries when the function returns an error, between 0 and 2

- (object) **`container_image_overrides = null`** _[since v1.0.0]_

    Container image configuration values that override the values in the container image Dockerfile. Only applicable if `code_source.container_image_uri` is specified

    - (string) **`cmd = null`** _[since v1.0.0]_

        Specifies parameters that you want to pass in with ENTRYPOINT

    - (string) **`entrypoint = null`** _[since v1.0.0]_

        Specifies the absolute path to the entry point of the application

    - (string) **`workdir = null`** _[since v1.0.0]_

        Specifies the absolute path to the working directory

- (object) **`concurrency = null`** _[since v1.0.0]_

    Configures [Lambda concurrency][lambda-concurrency]

    - (number) **`reserved_concurrency = -1`** _[since v1.0.0]_

        Specify the maximum number of concurrent instances allocated to the function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations

    - (map(number)) **`provisioned_concurrencies = {}`** _[since v1.0.0]_

        Map of provisioned concurrencies assigned to Lambda qualifiers. [See example](#provisioned-concurrency)

- (string) **`description = null`** _[since v1.0.0]_

    The description for this Lambda function

- (object) **`enable_active_tracing = null`** _[since v1.0.0]_

    Enables Lambda [active tracing with AWS X-Ray][lambda-active-tracing]

    - (string) **`mode = "Active"`** _[since v1.0.0]_

        Specifies the tracing mode. Valid values are: `"PassThrough"`, `"Active"`. If `"PassThrough"`, Lambda will only trace the request from an upstream service if it contains a tracing header with `"sampled=1"`. If `"Active"`, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision

- (object) **`enable_function_url = null`** _[since v1.0.0]_

    Enables [Lambda function URL][lambda-function-url], a dedicated HTTP(S) endpoint for the function

    - (string) **`auth_type = "AWS_IAM"`** _[since v1.0.0]_

        The type of authentication that the function URL uses. Valid values: `"AWS_IAM"`, `"NONE"` Set to `"AWS_IAM"` to restrict access to authenticated IAM users only. Set to `"NONE"` to bypass IAM authentication and create a public endpoint.

    - (string) **`invoke_mode = "BUFFERED"`** _[since v1.0.0]_

        Determines how the Lambda function responds to an invocation. Valid values are: `"BUFFERED"`, `"RESPONSE_STREAM"`

    - (object) **`cors_config = null`** _[since v1.0.0]_

        Configures the cross-origin resource sharing (CORS) settings for the function URL

        - (bool) **`allow_credentials = false`** _[since v1.0.0]_

            Whether to allow cookies or other credentials in requests to the function URL

        - (list(string)) **`allow_headers = null`** _[since v1.0.0]_

            The HTTP headers that origins can include in requests to the function URL. For example: `["date", "keep-alive", "x-custom-header"]`

        - (list(string)) **`allow_methods = ["*"]`** _[since v1.0.0]_

            The HTTP methods that are allowed when calling the function URL. For example: `["GET", "POST", "DELETE"]`

        - (list(string)) **`allow_origins = ["*"]`** _[since v1.0.0]_

            The origins that can access the function URL. For example: `["https://www.example.com", "http://localhost:60905"]`

        - (list(string)) **`expose_headers = null`** _[since v1.0.0]_

            The HTTP headers in your function response that you want to expose to origins that call the function URL

        - (number) **`max_age_seconds = 0`** _[since v1.0.0]_

            The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. Valid values: `0 - 86400`

- (object) **`environment_variables = null`** _[since v1.0.0]_

    Configures environment variables for the function

    - (map(string)) **`variables`** _[since v1.0.0]_

        A map of environment variables to pass to the function

    - (string) **`kms_key_arn = null`** _[since v1.0.0]_

        Specify the ARN of the KMS key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key

- (number) **`ephemeral_storage = 512`** _[since v1.0.0]_

    The size of the Lambda function Ephemeral storage(/tmp) in MB. Valid values: `512 - 10240`

- (string) **`execution_role_arn = null`** _[since v1.0.0]_

    Specify the ARN of the function's execution role. The role provides the function's identity and access to AWS services and resources. If not specified, a role will be generated and managed automatically by the module.

- (object) **`file_system_config = null`** _[since v1.0.0]_

    Connects the function to an EFS file system

    - (string) **`access_point_arn`** _[since v1.0.0]_

        ARN of the Amazon EFS Access Point that provides access to the file system

    - (string) **`local_mount_path`** _[since v1.0.0]_

        Path where the function can access the file system, Must starts with `"/mnt/"`

- (string) **`handler = null`** _[since v1.0.0]_

    Specify the function entrypoint in your code

- (map(object)) **`lambda_permissions = {}`** _[since v1.0.0]_

    Grants external sources such as AWS accounts and services permission to invoke the Lambda function. [See example](#lambda-permission)

    - (string) **`policy_type`** _[since v1.0.0]_

        The external source this policy is configured for. Valid values: `"aws_account"`, `"aws_service"`, `"function_url"`

    - (string) **`principal`** _[since v1.0.0]_

        Specify the principal who is getting this permission. If `policy_type = "aws_service"`, you must specify an AWS service URL such as `"s3.amazonaws.com"`. Otherwise, you can specify an AWS account ID such as `"111122223333"` or an IAM user ARN.

    - (string) **`action = null`** _[since v1.0.0]_

        The AWS Lambda action you want to allow in this statement. Defaults to `"lambda:InvokeFunctionUrl"` if `policy_type = "function_url"`, and `"lambda:InvokeFunction"` otherwise.

    - (string) **`event_source_token = null`** _[since v1.0.0]_

        The Event Source Token to validate. Valid only with an Alexa Skill principal.

    - (string) **`function_url_auth_type = null`** _[since v1.0.0]_

        Lambda Function URLs authentication type. Valid values: `"AWS_IAM"`, `"NONE"`. Only supported for `policy_type = "function_url"` and `action = "lambda:InvokeFunctionUrl"`

    - (string) **`principal_organization_id = null`** _[since v1.0.0]_

        The ID of an organization in AWS Organizations. Use this to grant permissions to only the AWS accounts under this organization.

    - (string) **`source_account_id = null`** _[since v1.0.0]_

        The AWS account ID of the source owner. Used to grant permissions to an AWS service outside of this function's account, such as an S3 bucket. Only valid if `policy_type = "aws_service"`

    - (string) **`source_arn = null`** _[since v1.0.0]_

        The ARN of the specific resource within that service to grant permission to, such as an S3 bucket ARN. Only valid if `policy_type = "aws_service"`

- (list(string)) **`layer_arns = []`** _[since v1.0.0]_

    List of [Lambda Layer][lambda-layer] Version ARNs (maximum of 5) to attach to your Lambda Function

- (number) **`memory = 128`** _[since v1.0.0]_

    Amount of memory in MB your Lambda Function can use at runtime. Valid values: `128 - 10240`

- (bool) **`publish_as_new_version = false`** _[since v1.0.0]_

    Whether to publish creation/change as new Lambda Function Version

- (string) **`runtime = null`** _[since v1.0.0]_

    Specify the language runtime. Please refer to [this documentation][lambda-runtime] for a list of valid values.

- (string) **`source_code_hash = null`** _[since v1.0.0]_

    Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the deployment package file. The usual way to set this is `filebase64sha256("source.zip")`. Only applicable if `code_source.filename` or `code_source.s3` is specified

- (number) **`timeout = 3`** _[since v1.0.0]_

    Specify timeout in seconds for the function, up to `900`

- (object) **`vpc_config = null`** _[since v1.0.0]_

    Configure this function to [connect to private subnets in a VPC][lambda-vpc-config], allowing it access to private resources. The required IAM policy will be automatically attached to the managed role if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided has the IAM policy `AWSLambdaENIManagementAccess` attached.

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        List of security group IDs associated with the ENIs of the Lambda function

    - (list(string)) **`subnet_ids`** _[since v1.0.0]_

        List of subnet IDs associated with the ENIs of the Lambda function

    - (bool) **`enable_dual_stack = false`** _[since v1.0.0]_

        Allows outbound IPv6 traffic on VPC functions that are connected to dual-stack subnets

## Outputs

- (string) **`function_arn`** _[since v1.0.0]_

    The ARN of the Lambda function

- (string) **`function_invoke_arn`** _[since v1.0.0]_

    ARN to be used for invoking Lambda Function from API Gateway

- (string) **`function_qualified_arn`** _[since v1.0.0]_

    ARN identifying the Lambda Function Version

- (string) **`function_qualified_invoke_arn`** _[since v1.0.0]_

    Qualified ARN (ARN with lambda version number) to be used for invoking Lambda Function from API Gateway

- (number) **`function_source_code_size`** _[since v1.0.0]_

    Size in bytes of the function's deployment package (.zip file)

- (object) **`function_version`** _[since v1.0.0]_

    Latest published version of the Lambda Function

- (object) **`function_url_endpoint`** _[since v1.0.0]_

    The HTTP URL endpoint for the function

[asynchronous-invocation-destination-permission]:https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html#invocation-async-destinations
[lambda-active-tracing]:https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html
[lambda-alias-routing]:https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html#configuring-alias-routing
[lambda-asynchronous-invocation]:https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
[lambda-concurrency]:https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html
[lambda-enhanced-monitoring]:https://docs.aws.amazon.com/lambda/latest/dg/monitoring-insights.html
[lambda-function-url]:https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html
[lambda-insight-extension-versions]:https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html
[lambda-layer]:https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
[lambda-runtime]:https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
[lambda-vpc-config]:https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
