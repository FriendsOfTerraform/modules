# Sagemaker Inference Module

This module builds and configures SageMaker inference models and endpoints

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
  source = "github.com/FriendsOfTerraform/aws-sagemaker-inference.git?ref=v1.0.0"

  # manages multiple models
  models = {
    # The keys of the map are model names
    demo-model = {
      iam_role_arn = "arn:aws:iam::111122223333:role/service-role/AmazonSageMakerServiceCatalogProductsExecutionRole"

      # manages multiple container definitions
      container_definitions = {
        # the keys of the map are DNS name for the containers
        container1 = {
          image               = "763104351884.dkr.ecr.us-east-1.amazonaws.com/tensorflow-inference:2.19.0"
          model_data_location = "s3://demo-bucket/demo-model.tar.gz"
        }
      }
    }
  }

  # manages multiple endpoints
  endpoints = {
    # the keys of the map are endpoint names
    realtime-endpoint = {
      provisioned = {
        production_variants = {
          # must refer to models created by this module
          demo-model = {
            instance_type  = "ml.m5.large"

            auto_scaling = {
              policies = {
                # the keys of the map are policy names
                builtin-policy            = { expression = "SageMakerVariantInvocationsPerInstance = 1000" }
                keep-invocations-near-100 = { expression = "Invocations average = 100" }
              }
            }

            cloudwatch_alarms = {
              # the keys of the map are alarm names
              invocations-greater-than-1000         = { expression = "Invocations average > 1000" }
              invocation-5xx-errors-greater-than-10 = { expression = "Invocation5XXErrors average >= 10" }
            }
          }
        }
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
    <td><code>map(object(<a href="#models">Models</a>))</code></td>
    <td width="100%">models</td>
    <td></td>
</tr>
<tr><td colspan="3">

Deploy multiple models.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
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
    <td><code>map(object(<a href="#endpoints">Endpoints</a>))</code></td>
    <td width="100%">endpoints</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple endpoints

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        </tbody></table>

## Objects

#### AsyncInvocationConfig

Specifies configuration for how an endpoint performs asynchronous inference

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">s3_output_path</td>
    <td></td>
</tr>
<tr><td colspan="3">

Location to upload response output on success. Must be an S3 url(s3 path)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">encryption_key</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an existing KMS key's ARN to encrypt your response output in S3.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">error_notification_location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

SNS topic to post a notification when inference fails. If no topic is provided, no notification is sent

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_concurrent_invocations_per_instance</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The maximum number concurrent requests sent to model container. If no value is provided, SageMaker chooses an optimal value.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">s3_failure_path</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Location to upload response output on failure. Must be an S3 url (s3 path).

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">success_notification_location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

SNS topic to post a notification when inference completes successfully. If no topic is provided, no notification is sent

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### AutoScaling

Enables auto scaling

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#policies">Policies</a>))</code></td>
    <td width="100%">policies</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages multiple auto scaling policies

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_capacity</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Specify the maximum number of EC2 instances to maintain.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">minimum_capacity</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Specify the minimum number of EC2 instances to maintain.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CaptureContentType

The content type headers to capture. Must specify one of `csv_text` or `json`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">csv_text</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The CSV content type headers to capture.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">json</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The JSON content type headers to capture.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### CloudwatchAlarms

Configures multiple Cloudwatch alarms.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

The expression in `<metric_name> <statistic> <comparison_operator> <threshold>` format. For example: `"Invocations average >= 100"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the alarm

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">evaluation_periods</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

The number of periods over which data is compared to the specified threshold.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">notification_sns_topic</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The SNS topic where notification will be sent

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">period</td>
    <td><code>"1 minute"</code></td>
</tr>
<tr><td colspan="3">

The period over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ContainerDefinitions

Container images containing inference code that are used when the model is deployed for predictions.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">image</td>
    <td></td>
</tr>
<tr><td colspan="3">

The registry path where the inference code image is stored in Amazon ECR

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">compression_type</td>
    <td><code>"CompressedModel"</code></td>
</tr>
<tr><td colspan="3">

Specify the model compression type.

**Allowed Values:**

- `CompressedModel`
- `UncompressedModel`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">environment_variables</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Environment variables for the container

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">model_data_location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The URL where model artifacts are stored in S3

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#usemultiplemodels">UseMultipleModels</a>)</code></td>
    <td width="100%">use_multiple_models</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configure this container to host multiple models

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### DataCaptureOptions

Specifies what data to capture.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">prediction_request</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Capture prediction requests (Input)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">prediction_response</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Capture prediction responses (Output)

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### EnableDataCapture

Enables data capture, where SageMaker can save prediction request and prediction response information from your endpoint to a specified location

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">s3_location_to_store_data_collected</td>
    <td></td>
</tr>
<tr><td colspan="3">

Amazon SageMaker will save the prediction requests and responses along with metadata for your endpoint at this location.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">sampling_percentage</td>
    <td><code>30</code></td>
</tr>
<tr><td colspan="3">

Amazon SageMaker will randomly sample and save the specified percentage of traffic to your endpoint.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#capturecontenttype">CaptureContentType</a>)</code></td>
    <td width="100%">capture_content_type</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The content type headers to capture. Must specify one of `csv_text` or `json`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#datacaptureoptions">DataCaptureOptions</a>)</code></td>
    <td width="100%">data_capture_options</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Specifies what data to capture.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Endpoints

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the endpoint

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">encryption_key</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an existing KMS key's ARN to encrypt your response output in S3.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#provisioned">Provisioned</a>)</code></td>
    <td width="100%">provisioned</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a provisioned endpoint, mutually exclusive to `serverless`. Must specify one of `provisioned` or `serverless`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#serverless">Serverless</a>)</code></td>
    <td width="100%">serverless</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a serverless endpoint, mutually exclusive to `provisioned`. Must specify one of `provisioned` or `serverless`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### InferenceExecutionConfig

Specifies details of how containers in a multi-container endpoint are called.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">mode</td>
    <td><code>"Serial"</code></td>
</tr>
<tr><td colspan="3">

How containers in a multi-container are run.

- `Serial`: containers run as a serial pipeline.
- `Direct`: only the individual container that you specify is run.

**Allowed Values:**

- `Serial`
- `Direct`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Models

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

A role that SageMaker AI can assume to access model artifacts and docker images for deployment

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#containerdefinitions">ContainerDefinitions</a>))</code></td>
    <td width="100%">container_definitions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Container images containing inference code that are used when the model is deployed for predictions.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#inferenceexecutionconfig">InferenceExecutionConfig</a>)</code></td>
    <td width="100%">inference_execution_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Specifies details of how containers in a multi-container endpoint are called.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the model

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_network_isolation</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled, containers cannot make any outbound network calls.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#vpcconfig">VpcConfig</a>)</code></td>
    <td width="100%">vpc_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies the VPC that you want your model to connect to. This is used in hosting services and in batch transform.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Policies

Manages multiple auto scaling policies

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

The expression in `<metric_name> <statistic> = <TargetValue>` format. For example: `"Invocations average = 100"`. If using a predefined metric such as `SageMakerVariantInvocationsPerInstance`, you can omit `<statistic>` from the expression. For example: `"SageMakerVariantInvocationsPerInstance = 100"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_scale_in</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Allow this Auto Scaling policy to scale-in (removing EC2 instances).

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scale_in_cooldown_period</td>
    <td><code>"5 minutes"</code></td>
</tr>
<tr><td colspan="3">

Specify the number of seconds to wait between scale-in actions.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scale_out_cooldown_period</td>
    <td><code>"5 minutes"</code></td>
</tr>
<tr><td colspan="3">

Specify the number of seconds to wait between scale-out actions.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ProductionVariants

Configure multiple production variants, one for each model that you want to host at this endpoint.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">instance_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

The EC2 instance type

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">container_startup_timeout</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The timeout value for the inference container to pass health check by SageMaker AI Hosting.

**Allowed Values:**

- `1 minute`
- `1 hour`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">initial_instance_count</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Specify the initial number of instances used for auto-scaling.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">initial_weight</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">model_data_download_timeout</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant.

**Allowed Values:**

- `1 minute`
- `1 hour`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">volume_size</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant.

**Allowed Values:**

- `1`
- `512`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#autoscaling">AutoScaling</a>)</code></td>
    <td width="100%">auto_scaling</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables auto scaling

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#cloudwatchalarms">CloudwatchAlarms</a>))</code></td>
    <td width="100%">cloudwatch_alarms</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple Cloudwatch alarms.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Provisioned

Creates a provisioned endpoint, mutually exclusive to `serverless`. Must specify one of `provisioned` or `serverless`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#productionvariants">ProductionVariants</a>))</code></td>
    <td width="100%">production_variants</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configure multiple production variants, one for each model that you want to host at this endpoint.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#asyncinvocationconfig">AsyncInvocationConfig</a>)</code></td>
    <td width="100%">async_invocation_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies configuration for how an endpoint performs asynchronous inference

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#enabledatacapture">EnableDataCapture</a>)</code></td>
    <td width="100%">enable_data_capture</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables data capture, where SageMaker can save prediction request and prediction response information from your endpoint to a specified location

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(object(<a href="#shadowvariants">ShadowVariants</a>))</code></td>
    <td width="100%">shadow_variants</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Specify shadow variants to receive production traffic replicated from the model specified on `production_variants`. If you use this field, you can only specify one variant for `production_variants` and one variant for `shadow_variants`.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Serverless

Creates a serverless endpoint, mutually exclusive to `provisioned`. Must specify one of `provisioned` or `serverless`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#variant">Variant</a>)</code></td>
    <td width="100%">variant</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures variant for this endpoint

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ShadowVariants

Specify shadow variants to receive production traffic replicated from the model specified on `production_variants`. If you use this field, you can only specify one variant for `production_variants` and one variant for `shadow_variants`.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">instance_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

The EC2 instance type

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">container_startup_timeout</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The timeout value for the inference container to pass health check by SageMaker AI Hosting. Valid values: `"1 minute"` - `"1 hour"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">initial_instance_count</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Specify the initial number of instances used for auto-scaling.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">initial_weight</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">model_data_download_timeout</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant. Valid values: `"1 minute"` - `"1 hour"`.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">volume_size</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values: `1` - `512`.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### UseMultipleModels

Configure this container to host multiple models

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_model_caching</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether to cache models for a multi-model endpoint. By default, multi-model endpoints cache models so that a model does not have to be loaded into memory each time it is invoked. Some use cases do not benefit from model caching. For example, if an endpoint hosts a large number of models that are each invoked infrequently, the endpoint might perform better if you disable model caching.

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### Variant

Configures variant for this endpoint

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">model_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the model to be used for this endpoint. The model specified must be managed by the same module

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_concurrency</td>
    <td><code>20</code></td>
</tr>
<tr><td colspan="3">

The maximum number of concurrent invocations your serverless endpoint can process. Valid values: `1` - `200`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">memory_size</td>
    <td><code>1024</code></td>
</tr>
<tr><td colspan="3">

The memory size of your serverless endpoint.

**Allowed Values:**

- `1024`
- `2048`
- `3072`
- `4096`
- `5120`
- `6144`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">provisioned_concurrency</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Provisioned concurrency enables you to deploy models on serverless endpoints with predictable performance and high scalability. For the set number of concurrent invocations, SageMaker will keep underlying compute warm and ready to respond instantaneously without cold starts. Must be `<= max_concurrency`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### VpcConfig

Specifies the VPC that you want your model to connect to. This is used in hosting services and in batch transform.

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of security group IDs the models use to access private resources

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of subnet IDs to be used for this VPC connection

**Since:** 1.0.0

</td></tr>
</tbody></table>

<!-- TFDOCS_EXTRAS_END -->
