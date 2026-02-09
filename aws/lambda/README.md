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
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#codesource">CodeSource</a>)</code></td>
    <td width="100%">code_source</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the code source. Exactly one of `container_image_uri`, `filename`, or `s3` must be specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the Lambda function. All associated resources' names will also be prefixed by this value

**Since:** 1.0.0

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">additional_execution_role_policies</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

Additional IAM policies to be attached to the managed execution IAM role. This is ignored if `execution_role_arn` is specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the Lambda function

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
    <td><code>map(object(<a href="#aliases">Aliases</a>))</code></td>
    <td width="100%">aliases</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple Lambda aliases.

**Examples:**

- [Versioning And Aliases](#versioning-and-aliases)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">architecture</td>
    <td><code>"x86_64"</code></td>
</tr>
<tr><td colspan="3">

Specify the instruction set architecture for this Lambda function.

**Allowed Values:**

- `x86_64`
- `arm64`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#asynchronousinvocation">AsynchronousInvocation</a>)</code></td>
    <td width="100%">asynchronous_invocation</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures error handling and destinations for [asynchronous invocation][lambda-asynchronous-invocation].

**Examples:**

- [Asynchronous Invocation Configuration](#asynchronous-invocation-configuration)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#concurrency">Concurrency</a>)</code></td>
    <td width="100%">concurrency</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [Lambda concurrency][lambda-concurrency]

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#containerimageoverrides">ContainerImageOverrides</a>)</code></td>
    <td width="100%">container_image_overrides</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Container image configuration values that override the values in the container image Dockerfile. Only applicable if `code_source.container_image_uri` is specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description for this Lambda function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#enableactivetracing">EnableActiveTracing</a>)</code></td>
    <td width="100%">enable_active_tracing</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables Lambda [active tracing with AWS X-Ray][lambda-active-tracing]

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#enablefunctionurl">EnableFunctionUrl</a>)</code></td>
    <td width="100%">enable_function_url</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables [Lambda function URL][lambda-function-url], a dedicated HTTP(S) endpoint for the function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#environmentvariables">EnvironmentVariables</a>)</code></td>
    <td width="100%">environment_variables</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures environment variables for the function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">ephemeral_storage</td>
    <td><code>512</code></td>
</tr>
<tr><td colspan="3">

The size of the Lambda function Ephemeral storage(/tmp) in MB. Valid values: `512 - 10240`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">execution_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the ARN of the function's execution role. The role provides the function's identity and access to AWS services and resources. If not specified, a role will be generated and managed automatically by the module.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#filesystemconfig">FileSystemConfig</a>)</code></td>
    <td width="100%">file_system_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Connects the function to an EFS file system

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">handler</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the function entrypoint in your code

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#lambdapermissions">LambdaPermissions</a>))</code></td>
    <td width="100%">lambda_permissions</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Grants external sources such as AWS accounts and services permission to invoke the Lambda function.

**Examples:**

- [Lambda Permission](#lambda-permission)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">layer_arns</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of [Lambda Layer][lambda-layer] Version ARNs (maximum of 5) to attach to your Lambda Function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">memory</td>
    <td><code>128</code></td>
</tr>
<tr><td colspan="3">

Amount of memory in MB your Lambda Function can use at runtime. Valid values: `128 - 10240`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">publish_as_new_version</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to publish creation/change as new Lambda Function Version

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">runtime</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the language runtime. Please refer to [this documentation][lambda-runtime] for a list of valid values.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_code_hash</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the deployment package file. The usual way to set this is `filebase64sha256("source.zip")`. Only applicable if `code_source.filename` or `code_source.s3` is specified

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">timeout</td>
    <td><code>3</code></td>
</tr>
<tr><td colspan="3">

Specify timeout in seconds for the function, up to `900`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#vpcconfig">VpcConfig</a>)</code></td>
    <td width="100%">vpc_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configure this function to [connect to private subnets in a VPC][lambda-vpc-config], allowing it access to private resources. The required IAM policy will be automatically attached to the managed role if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided has the IAM policy `AWSLambdaENIManagementAccess` attached.

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">function_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the Lambda function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">function_invoke_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN to be used for invoking Lambda Function from API Gateway

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">function_qualified_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN identifying the Lambda Function Version

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">function_qualified_invoke_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Qualified ARN (ARN with lambda version number) to be used for invoking Lambda Function from API Gateway

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">function_source_code_size</td>
    <td></td>
</tr>
<tr><td colspan="3">

Size in bytes of the function's deployment package (.zip file)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object</code></td>
    <td width="100%">function_url_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

The HTTP URL endpoint for the function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object</code></td>
    <td width="100%">function_version</td>
    <td></td>
</tr>
<tr><td colspan="3">

Latest published version of the Lambda Function

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### Aliases

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">function_version</td>
    <td></td>
</tr>
<tr><td colspan="3">

Lambda function version for which you are creating the alias

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Description of the alias

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#weightedalias">WeightedAlias</a>)</code></td>
    <td width="100%">weighted_alias</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures this alias to send a portion of traffic to a second function version. Used for canary deployment scenarios. Please refer to [this documentation][lambda-alias-routing] for a list of requirements for this feature.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### AsynchronousInvocation

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">on_failure_destination_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the ARN of the destination for failed asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">on_success_destination_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the ARN of the destination for successful asynchronous invocations. This ARN must be one of the following resources: SNS, SQS, Lambda, or an EventBus. The required IAM policies will be automatically generated if `execution_role_arn` is not specified, otherwise, please make sure the execution role you provided [has the proper permissions][asynchronous-invocation-destination-permission].

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#retries">Retries</a>)</code></td>
    <td width="100%">retries</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures error handling

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CodeSource

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">container_image_uri</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the Amazon ECR image URI of the container image to use for this function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">filename</td>
    <td></td>
</tr>
<tr><td colspan="3">

Path to the function's deployment package within the local filesystem

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#s3">S3</a>)</code></td>
    <td width="100%">s3</td>
    <td></td>
</tr>
<tr><td colspan="3">

S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region where you are creating the Lambda function

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Concurrency

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">reserved_concurrency</td>
    <td><code>-1</code></td>
</tr>
<tr><td colspan="3">

Specify the maximum number of concurrent instances allocated to the function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(number)</code></td>
    <td width="100%">provisioned_concurrencies</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of provisioned concurrences assigned to Lambda qualifiers.

**Examples:**

- [Provisioned Concurrency](#provisioned-concurrency)

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ContainerImageOverrides

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cmd</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies parameters that you want to pass in with ENTRYPOINT

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">entrypoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the absolute path to the entry point of the application

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">workdir</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the absolute path to the working directory

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CorsConfig

Configures the cross-origin resource sharing (CORS) settings for the function URL

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">allow_credentials</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to allow cookies or other credentials in requests to the function URL

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_headers</td>
    <td></td>
</tr>
<tr><td colspan="3">

The HTTP headers that origins can include in requests to the function URL. For example: `["date", "keep-alive", "x-custom-header"]`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_methods</td>
    <td></td>
</tr>
<tr><td colspan="3">

The HTTP methods that are allowed when calling the function URL. For example: `["GET", "POST", "DELETE"]`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allow_origins</td>
    <td></td>
</tr>
<tr><td colspan="3">

The origins that can access the function URL. For example: `["https://www.example.com", "http://localhost:60905"]`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">expose_headers</td>
    <td></td>
</tr>
<tr><td colspan="3">

The HTTP headers in your function response that you want to expose to origins that call the function URL

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_age_seconds</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. Valid values: `0 - 86400`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnableActiveTracing

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">mode</td>
    <td><code>"Active"</code></td>
</tr>
<tr><td colspan="3">

Specifies the tracing mode. If `"PassThrough"`, Lambda will only trace the request from an upstream service if it contains a tracing header with `"sampled=1"`. If `"Active"`, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision

**Allowed Values:**

- `PassThrough`
- `Active`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnableFunctionUrl

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">auth_type</td>
    <td><code>"AWS_IAM"</code></td>
</tr>
<tr><td colspan="3">

The type of authentication that the function URL uses. Set to `"NONE"` to bypass IAM authentication and create a public endpoint.

**Allowed Values:**

- `AWS_IAM`
- `NONE`
- `AWS_IAM`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">invoke_mode</td>
    <td><code>"BUFFERED"</code></td>
</tr>
<tr><td colspan="3">

Determines how the Lambda function responds to an invocation.

**Allowed Values:**

- `BUFFERED`
- `RESPONSE_STREAM`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#corsconfig">CorsConfig</a>)</code></td>
    <td width="100%">cors_config</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the cross-origin resource sharing (CORS) settings for the function URL

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnvironmentVariables

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">variables</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of environment variables to pass to the function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the ARN of the KMS key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### FileSystemConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_point_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the Amazon EFS Access Point that provides access to the file system

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">local_mount_path</td>
    <td></td>
</tr>
<tr><td colspan="3">

Path where the function can access the file system; must start with `/mnt/`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### LambdaPermissions

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">policy_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

The external source this policy is configured for.

**Allowed Values:**

- `aws_account`
- `aws_service`
- `function_url`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">principal</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the principal who is getting this permission. If `policy_type = "aws_service"`, you must specify an AWS service URL such as `"s3.amazonaws.com"`. Otherwise, you can specify an AWS account ID such as `"111122223333"` or an IAM user ARN.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">action</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS Lambda action you want to allow in this statement. Defaults to `"lambda:InvokeFunctionUrl"` if `policy_type = "function_url"`, and `"lambda:InvokeFunction"` otherwise.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">event_source_token</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Event Source Token to validate. Valid only with an Alexa Skill principal.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">function_url_auth_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Lambda Function URLs authentication type. Only supported for `policy_type = "function_url"` and `action = "lambda:InvokeFunctionUrl"`

**Allowed Values:**

- `AWS_IAM`
- `NONE`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">principal_organization_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of an organization in AWS Organizations. Use this to grant permissions to only the AWS accounts under this organization.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_account_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS account ID of the source owner. Used to grant permissions to an AWS service outside of this function's account, such as an S3 bucket. Only valid if `policy_type = "aws_service"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the specific resource within that service to grant permission to, such as an S3 bucket ARN. Only valid if `policy_type = "aws_service"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Retries

Configures error handling

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">maximum_event_age_in_seconds</td>
    <td><code>21600</code></td>
</tr>
<tr><td colspan="3">

The maximum amount of time Lambda retains an event in the asynchronous event queue, up to 6 hours

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_retry_attempts</td>
    <td><code>2</code></td>
</tr>
<tr><td colspan="3">

The number of times Lambda retries when the function returns an error, between 0 and 2

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### S3

S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region where you are creating the Lambda function

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">uri</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the S3 URI of the deployment package to use for this function.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">version</td>
    <td></td>
</tr>
<tr><td colspan="3">

Object version containing the function's deployment package

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### VpcConfig

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of security group IDs associated with the ENIs of the Lambda function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of subnet IDs associated with the ENIs of the Lambda function

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_dual_stack</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Allows outbound IPv6 traffic on VPC functions that are connected to dual-stack subnets

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### WeightedAlias

Configures this alias to send a portion of traffic to a second function version. Used for canary deployment scenarios. Please refer to [this documentation][lambda-alias-routing] for a list of requirements for this feature.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">function_version</td>
    <td></td>
</tr>
<tr><td colspan="3">

The second function version to route portion of the traffic to

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td></td>
</tr>
<tr><td colspan="3">

The weight, in percentage, of the total traffic routed to the second function version

**Since:** 1.0.0

</td></tr>
</tbody></table>

[asynchronous-invocation-destination-permission]: https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html#invocation-async-destinations
[lambda-active-tracing]: https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html
[lambda-alias-routing]: https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html#configuring-alias-routing
[lambda-asynchronous-invocation]: https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
[lambda-concurrency]: https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html
[lambda-function-url]: https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html
[lambda-layer]: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
[lambda-runtime]: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
[lambda-vpc-config]: https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html

<!-- TFDOCS_EXTRAS_END -->

[lambda-enhanced-monitoring]: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-insights.html
[lambda-insight-extension-versions]: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html
