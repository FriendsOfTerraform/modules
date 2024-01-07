resource "aws_lambda_function" "function" {
  function_name                  = var.name
  role                           = local.execution_role_provided ? var.execution_role_arn : aws_iam_role.lambda_iam_role[0].arn
  architectures                  = [var.architecture]
  description                    = var.description
  filename                       = var.code_source.filename
  handler                        = var.handler
  image_uri                      = var.code_source.container_image_uri
  kms_key_arn                    = var.environment_variables != null ? var.environment_variables.kms_key_arn : null
  memory_size                    = var.memory
  package_type                   = var.code_source.container_image_uri != null ? "Image" : "Zip"
  publish                        = var.publish_as_new_version
  reserved_concurrent_executions = var.concurrency != null ? var.concurrency.reserved_concurrency : null
  runtime                        = var.runtime
  s3_bucket                      = var.code_source.s3 != null ? split("/", var.code_source.s3.uri)[2] : null
  s3_object_version              = var.code_source.s3 != null ? var.code_source.s3.version : null
  source_code_hash               = var.source_code_hash
  timeout                        = var.timeout

  # Generate s3 object key from the s3 uri by joining all the elements with "/" after bucket name (in position 2)
  s3_key = var.code_source.s3 != null ? join("/", [
    for i in range(3, length(split("/", var.code_source.s3.uri))) : split("/", var.code_source.s3.uri)[i]
  ]) : null

  dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []

    content {
      variables = var.environment_variables.variables
    }
  }

  ephemeral_storage {
    size = var.ephemeral_storage
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [1] : []

    content {
      arn              = var.file_system_config.access_point_arn
      local_mount_path = var.file_system_config.local_mount_path
    }
  }

  dynamic "image_config" {
    for_each = var.container_image_overrides != null ? [1] : []

    content {
      command           = var.container_image_overrides.cmd
      entry_point       = var.container_image_overrides.entrypoint
      working_directory = var.container_image_overrides.workdir
    }
  }

  layers = concat(
    var.layer_arns, []
    //var.enable_enhanced_monitoring ? [data.aws_lambda_layer_version.lambda_insights_extension[0].arn] : []
  )

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  dynamic "tracing_config" {
    for_each = var.enable_active_tracing != null ? [1] : []

    content {
      mode = var.enable_active_tracing.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      ipv6_allowed_for_dual_stack = var.vpc_config.enable_dual_stack
      security_group_ids          = var.vpc_config.security_group_ids
      subnet_ids                  = var.vpc_config.subnet_ids
    }
  }
}
