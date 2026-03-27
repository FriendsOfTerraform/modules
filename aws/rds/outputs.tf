output "aurora_cluster_endpoint" {
  description = <<EOT
    DNS address of the Writer instance

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].endpoint
  ) : null
}

output "aurora_cluster_members" {
  description = <<EOT
    List of RDS Instances that are a part of this Aurora cluster

    @type list(string)
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].cluster_members
  ) : null
}

output "aurora_cluster_reader_endpoint" {
  description = <<EOT
    Read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].reader_endpoint
  ) : null
}

output "aurora_global_cluster_arn" {
  description = <<EOT
    The ARN of the Aurora global cluster created by this module

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    var.aurora_global_cluster != null ? (
      var.aurora_global_cluster.name != null ? aws_rds_global_cluster.global_cluster[0].arn : null
    ) : null
  ) : null
}

output "aurora_global_cluster_identifier" {
  description = <<EOT
    The name of the Aurora global cluster created by this module

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    var.aurora_global_cluster != null ? (
      var.aurora_global_cluster.name != null ? aws_rds_global_cluster.global_cluster[0].id : null
    ) : null
  ) : null
}

output "cluster_arn" {
  description = <<EOT
    The ARN of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].arn
  ) : var.deployment_option == "MultiAZCluster" ? aws_rds_cluster.multi_az_cluster[0].arn : null
}

output "cluster_identifier" {
  description = <<EOT
    The name of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

    @type string
    @since 1.0.0
  EOT
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].cluster_identifier
  ) : var.deployment_option == "MultiAZCluster" ? aws_rds_cluster.multi_az_cluster[0].cluster_identifier : null
}

output "master_user_secret" {
  description = <<EOT
    Retrieve master user secret. Only available when `authentication_config.db_master_account.manage_password_in_secrets_manager = true`

    @type map(object({
      /// Amazon Web Services KMS key identifier that is used to encrypt the secret.
      ///
      /// @since 1.0.0
      kms_key_id = string

      /// Amazon Resource Name (ARN) of the secret.
      ///
      /// @since 1.0.0
      secret_arn = string

      /// Status of the secret
      ///
      /// @enum creating|active|rotating|impaired
      /// @since 1.0.0
      secret_status = string
    }))
    @since 1.0.0
  EOT
  value = var.authentication_config.db_master_account.manage_password_in_secrets_manager != null ? (
    local.is_aurora ? (
      aws_rds_cluster.aurora_cluster[0].master_user_secret
      ) : var.deployment_option == "MultiAZCluster" ? (
      aws_rds_cluster.multi_az_cluster[0].master_user_secret
    ) : aws_db_instance.db_instance[0].master_user_secret
  ) : null
}

output "rds_connect_iam_policy_arns" {
  description = <<EOT
    The map of IAM policy ARNs for RDS connect. Only available when `authentication_config.iam_database_authentication.enabled = true`

    @type map(string)
    @since 1.0.0
  EOT
  value = var.authentication_config.iam_database_authentication != null ? (
    { for k, v in aws_iam_policy.rds_connection_policies : k => v.arn }
  ) : null
}
