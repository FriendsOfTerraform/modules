# Sagemaker Inference Module

This module builds and configures SageMaker inference models and endpoints

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

## Argument Reference

### Mandatory

- (map(object)) **`models`** _[since v1.0.0]_

    Deploy multiple models. Please [see example](#basic-usage)

    - (map(object)) **`container_definitions`** _[since v1.0.0]_

        Container images containing inference code that are used when the model is deployed for predictions.

        - (string) **`image`** _[since v1.0.0]_

            The registry path where the inference code image is stored in Amazon ECR

        - (string) **`compression_type = "CompressedModel"`** _[since v1.0.0]_

            Specify the model compression type. Valid values: `"CompressedModel"`, `"UncompressedModel"`

        - (map(string)) **`environment_variables = {}`** _[since v1.0.0]_

            Environment variables for the container

        - (string) **`model_data_location = null`** _[since v1.0.0]_

            The URL where model artifacts are stored in S3

        - (object) **`use_multiple_models = null`** _[since v1.0.0]_

            Configure this container to host multiple models

            - (bool) **`enable_model_caching = true`** _[since v1.0.0]_

                Whether to cache models for a multi-model endpoint. By default, multi-model endpoints cache models so that a model does not have to be loaded into memory each time it is invoked. Some use cases do not benefit from model caching. For example, if an endpoint hosts a large number of models that are each invoked infrequently, the endpoint might perform better if you disable model caching.

    - (string) **`iam_role_arn`** _[since v1.0.0]_

        A role that SageMaker AI can assume to access model artifacts and docker images for deployment

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the model

    - (bool) **`enable_network_isolation = false`** _[since v1.0.0]_

        If enabled, containers cannot make any outbound network calls.

    - (object) **`inference_execution_config = {}`** _[since v1.0.0]_

        Specifies details of how containers in a multi-container endpoint are called.

      - (string) **`mode = "Serial"`** _[since v1.0.0]_

          How containers in a multi-container are run. Valid values: `"Serial"` - Containers run as a serial pipeline. `"Direct"` - Only the individual container that you specify is run.

    - (object) **`vpc_config = null`** _[since v1.0.0]_

        Specifies the VPC that you want your model to connect to. This is used in hosting services and in batch transform.

        - (list(string)) **`security_group_ids`** _[since v1.0.0]_

            List of security group IDs the models use to access private resources

        - (list(string)) **`subnet_ids`** _[since v1.0.0]_

            List of subnet IDs to be used for this VPC connection

### Optional

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`endpoints = {}`** _[since v1.0.0]_

    Configures multiple endpoints

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the endpoint

    - (string) **`encryption_key = null`** _[since v1.0.0]_

        Specify an existing KMS key's ARN to encrypt your response output in S3.

    - (object) **`provisioned = null`** _[since v1.0.0]_

        Creates a provisioned endpoint, mutually exclusive to `serverless`. Must specify one of `provisioned` or `serverless`

        - (map(object)) **`production_variants`** _[since v1.0.0]_

            Configure multiple production variants, one for each model that you want to host at this endpoint.

            - (string) **`instance_type`** _[since v1.0.0]_

                The EC2 instance type

            - (object) **`auto_scaling = null`** _[since v1.0.0]_

                Enables auto scaling

                - (map(object)) **`policies`** _[since v1.0.0]_

                    Manages multiple auto scaling policies

                    - (string) **`expression`** _[since v1.0.0]_

                        The expression in `<metric_name> <statistic> = <TargetValue>` format. For example: `"Invocations average = 100"`. If using a predefined metric such as `SageMakerVariantInvocationsPerInstance`, you can omit `<statistic>` from the expression. For example: `"SageMakerVariantInvocationsPerInstance = 100"`

                    - (bool) **`enable_scale_in = true`** _[since v1.0.0]_

                        Allow this Auto Scaling policy to scale-in (removing EC2 instances).

                    - (string) **`scale_in_cooldown_period = "5 minutes"`** _[since v1.0.0]_

                        Specify the number of seconds to wait between scale-in actions.

                    - (string) **`scale_out_cooldown_period = "5 minutes"`** _[since v1.0.0]_

                        Specify the number of seconds to wait between scale-out actions.

                - (number) **`maximum_capacity = 1`** _[since v1.0.0]_

                    Specify the maximum number of EC2 instances to maintain.

                - (number) **`minimum_capacity = 1`** _[since v1.0.0]_

                    Specify the minimum number of EC2 instances to maintain.

            - (map(object)) **`cloudwatch_alarms = {}`** _[since v1.0.0]_

                Configures multiple Cloudwatch alarms. Please see [example](#basic-usage)

                - (string) **`expression`** _[since v1.0.0]_

                    The expression in `<metric_name> <statistic> <comparison_operator> <threshold>` format. For example: `"Invocations average >= 100"`

                - (string) **`description = null`** _[since v1.0.0]_

                    The description of the alarm

                - (number) **`evaluation_periods = 1`** _[since v1.0.0]_

                    The number of periods over which data is compared to the specified threshold.

                - (string) **`notification_sns_topic = null`** _[since v1.0.0]_

                    The SNS topic where notification will be sent

                - (string) **`period = "1 minute"`** _[since v1.0.0]_

                    The period over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`

            - (string) **`container_startup_timeout = null`** _[since v1.0.0]_

                The timeout value for the inference container to pass health check by SageMaker AI Hosting. Valid values: `"1 minute"` - `"1 hour"`.

            - (number) **`initial_instance_count = 1`** _[since v1.0.0]_

                Specify the initial number of instances used for auto-scaling.

            - (number) **`initial_weight = 1`** _[since v1.0.0]_

                Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.

            - (string) **`model_data_download_timeout = null`** _[since v1.0.0]_

                The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant. Valid values: `"1 minute"` - `"1 hour"`.

            - (number) **`volume_size = null`** _[since v1.0.0]_

                The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values: `1` - `512`.

        - (object) **`async_invocation_config = null`** _[since v1.0.0]_

            Specifies configuration for how an endpoint performs asynchronous inference

            - (string) **`s3_output_path`** _[since v1.0.0]_

                Location to upload response output on success. Must be an S3 url(s3 path)

            - (string) **`encryption_key = null`** _[since v1.0.0]_

                Specify an existing KMS key's ARN to encrypt your response output in S3.

            - (string) **`error_notification_location = null`** _[since v1.0.0]_

                SNS topic to post a notification when inference fails. If no topic is provided, no notification is sent

            - (number) **`max_concurrent_invocations_per_instance = null`** _[since v1.0.0]_

                The maximum number concurrent requests sent to model container. If no value is provided, SageMaker chooses an optimal value.

            - (string) **`s3_failure_path = null`** _[since v1.0.0]_

                Location to upload response output on failure. Must be an S3 url (s3 path).

            - (string) **`success_notification_location = null`** _[since v1.0.0]_

                SNS topic to post a notification when inference completes successfully. If no topic is provided, no notification is sent

        - (object) **`enable_data_capture = null`** _[since v1.0.0]_

            Enables data capture, where SageMaker can save prediction request and prediction response information from your endpoint to a specified location

            - (string) **`s3_location_to_store_data_collected`** _[since v1.0.0]_

                Amazon SageMaker will save the prediction requests and responses along with metadata for your endpoint at this location.

            - (object) **`capture_content_type = null`** _[since v1.0.0]_

                The content type headers to capture. Must specify one of `csv_text` or `json`

                - (list(string)) **`csv_text = null`** _[since v1.0.0]_

                    The CSV content type headers to capture.

                - (list(string)) **`json = null`** _[since v1.0.0]_

                    The JSON content type headers to capture.

            - (object) **`data_capture_options = {}`** _[since v1.0.0]_

                Specifies what data to capture.

                - (bool) **`prediction_request = true`** _[since v1.0.0]_

                    Capture prediction requests (Input)

                - (bool) **`prediction_response = true`** _[since v1.0.0]_

                    Capture prediction responses (Output)

            - (number) **`sampling_percentage = 30`** _[since v1.0.0]_

                Amazon SageMaker will randomly sample and save the specified percentage of traffic to your endpoint.

        - (map(object)) **`shadow_variants = {}`** _[since v1.0.0]_

            Specify shadow variants to receive production traffic replicated from the model specified on `production_variants`. If you use this field, you can only specify one variant for `production_variants` and one variant for `shadow_variants`.

            - (string) **`instance_type`** _[since v1.0.0]_

                The EC2 instance type

            - (string) **`container_startup_timeout = null`** _[since v1.0.0]_

                The timeout value for the inference container to pass health check by SageMaker AI Hosting. Valid values: `"1 minute"` - `"1 hour"`.

            - (number) **`initial_instance_count = 1`** _[since v1.0.0]_

                Specify the initial number of instances used for auto-scaling.

            - (number) **`initial_weight = 1`** _[since v1.0.0]_

                Determines initial traffic distribution among all of the models that you specify in the endpoint configuration.

            - (string) **`model_data_download_timeout = null`** _[since v1.0.0]_

                The timeout value to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant. Valid values: `"1 minute"` - `"1 hour"`.

            - (number) **`volume_size = null`** _[since v1.0.0]_

                The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values: `1` - `512`.

    - (object) **`serverless = null`** _[since v1.0.0]_

        Creates a serverless endpoint, mutually exclusive to `provisioned`. Must specify one of `provisioned` or `serverless`

        - (object) **`variant`** _[since v1.0.0]_

            Configures variant for this endpoint

            - (string) **`model_name`** _[since v1.0.0]_

                The name of the model to be used for this endpoint. The model specified must be managed by the same module

            - (number) **`max_concurrency = 20`** _[since v1.0.0]_

                The maximum number of concurrent invocations your serverless endpoint can process. Valid values: `1` - `200`

            - (number) **`memory_size = 1024`** _[since v1.0.0]_

                The memory size of your serverless endpoint. Valid values: `1024`, `2048`, `3072`, `4096`, `5120`, `6144`.

            - (number) **`provisioned_concurrency = null`** _[since v1.0.0]_

                Provisioned concurrency enables you to deploy models on serverless endpoints with predictable performance and high scalability. For the set number of concurrent invocations, SageMaker will keep underlying compute warm and ready to respond instantaneously without cold starts. Must be `<= max_concurrency`

