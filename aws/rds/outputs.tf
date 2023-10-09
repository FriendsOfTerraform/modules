output "aurora_cluster_endpoint" {
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].endpoint
  ) : null
}

output "aurora_cluster_members" {
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].cluster_members
  ) : null
}

output "aurora_cluster_reader_endpoint" {
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].reader_endpoint
  ) : null
}

output "aurora_global_cluster_arn" {
  value = local.is_aurora ? (
    var.aurora_global_cluster != null ? (
      var.aurora_global_cluster.name != null ? aws_rds_global_cluster.global_cluster[0].arn : null
    ) : null
  ) : null
}

output "aurora_global_cluster_identifier" {
  value = local.is_aurora ? (
    var.aurora_global_cluster != null ? (
      var.aurora_global_cluster.name != null ? aws_rds_global_cluster.global_cluster[0].id : null
    ) : null
  ) : null
}

output "cluster_arn" {
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].arn
  ) : var.deployment_option == "MultiAZCluster" ? aws_rds_cluster.multi_az_cluster[0].arn : null
}

output "cluster_identifier" {
  value = local.is_aurora ? (
    aws_rds_cluster.aurora_cluster[0].cluster_identifier
  ) : var.deployment_option == "MultiAZCluster" ? aws_rds_cluster.multi_az_cluster[0].cluster_identifier : null
}

output "master_user_secret" {
  value = var.authentication_config.db_master_account.manage_password_in_secrets_manager != null ? (
    local.is_aurora ? (
      aws_rds_cluster.aurora_cluster[0].master_user_secret
      ) : var.deployment_option == "MultiAZCluster" ? (
      aws_rds_cluster.multi_az_cluster[0].master_user_secret
    ) : aws_db_instance.db_instance[0].master_user_secret
  ) : null
}
