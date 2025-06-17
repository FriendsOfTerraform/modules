######################
## Multi-AZ Cluster ##
######################

resource "aws_rds_cluster" "multi_az_cluster" {
  count = local.is_aurora ? 0 : (var.deployment_option == "MultiAZCluster" ? 1 : 0)

  apply_immediately = var.apply_immediately

  # Engine options
  engine         = var.engine.type
  engine_version = var.engine.version

  # Settings
  cluster_identifier = var.name

  # Credentials Settings
  master_username               = var.authentication_config.db_master_account.username
  master_password               = var.authentication_config.db_master_account.password
  manage_master_user_password   = var.authentication_config.db_master_account.manage_password_in_secrets_manager
  master_user_secret_kms_key_id = var.authentication_config.db_master_account.customer_kms_key_id

  # Instance Configuration
  db_cluster_instance_class = var.instance_class

  # Storage
  storage_type      = "io1"
  allocated_storage = var.storage_config != null ? var.storage_config.allocated_storage : null
  iops              = var.storage_config != null ? var.storage_config.provisioned_iops : null

  # Connectivity
  db_subnet_group_name   = var.networking_config.db_subnet_group_name
  vpc_security_group_ids = var.networking_config.security_group_ids
  port                   = var.networking_config.port

  # Database Authentication
  iam_database_authentication_enabled = var.authentication_config.iam_database_authentication != null ? var.authentication_config.iam_database_authentication.enabled : null

  # Monitoring
  database_insights_mode                = var.database_insights
  performance_insights_enabled          = local.is_performance_insight_enabled
  performance_insights_retention_period = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.retention_period : null
  performance_insights_kms_key_id       = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.kms_key_id : null
  monitoring_interval                   = local.is_enhanced_monitoring_enabled ? var.monitoring_config.enable_enhanced_monitoring.interval : 0

  monitoring_role_arn = local.is_enhanced_monitoring_enabled ? (
    var.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? var.monitoring_config.enable_enhanced_monitoring.iam_role_arn : aws_iam_role.rds_enhanced_monitoring[0].arn
  ) : null

  # Additional Configuration
  # Database Options
  db_cluster_parameter_group_name = var.db_cluster_parameter_group

  # Backup
  backup_retention_period = var.enable_automated_backup != null ? var.enable_automated_backup.retention_period : 1
  preferred_backup_window = var.enable_automated_backup != null ? var.enable_automated_backup.window : null

  # Encryption
  storage_encrypted = var.enable_encryption != null ? true : false
  kms_key_id        = var.enable_encryption != null ? var.enable_encryption.kms_key_arn : null

  # Log exports
  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports

  # Maintenance
  preferred_maintenance_window = var.maintenance_config != null ? var.maintenance_config.window : null

  # Delete protection
  deletion_protection = var.delete_protection_enabled

  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}

####################
## Aurora Cluster ##
####################

resource "aws_rds_cluster" "aurora_cluster" {
  count = local.is_aurora ? 1 : 0

  apply_immediately = var.apply_immediately

  # Aurora global cluster
  global_cluster_identifier = var.aurora_global_cluster != null ? (
    var.aurora_global_cluster.name != null ? var.aurora_global_cluster.name : var.aurora_global_cluster.join_existing_global_cluster
  ) : null

  # Engine options
  engine         = var.engine.type
  engine_version = var.engine.version
  engine_mode    = var.instance_class == "db.serverless" ? "provisioned" : null

  # Settings
  cluster_identifier = var.name

  # Credentials Settings
  master_username               = var.authentication_config.db_master_account.username
  master_password               = var.authentication_config.db_master_account.password
  manage_master_user_password   = var.authentication_config.db_master_account.manage_password_in_secrets_manager
  master_user_secret_kms_key_id = var.authentication_config.db_master_account.customer_kms_key_id

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.instance_class == "db.serverless" ? [1] : []

    content {
      max_capacity = var.serverless_capacity != null ? (
        var.serverless_capacity.max_acus != null ? var.serverless_capacity.max_acus : var.serverless_capacity.min_acus
      ) : 64

      min_capacity = var.serverless_capacity != null ? var.serverless_capacity.min_acus : 8
    }
  }

  # Connectivity
  network_type           = var.networking_config.enable_ipv6 ? "DUAL" : "IPV4"
  db_subnet_group_name   = var.networking_config.db_subnet_group_name
  vpc_security_group_ids = var.networking_config.security_group_ids
  port                   = var.networking_config.port

  # Database Authentication
  iam_database_authentication_enabled = var.authentication_config.iam_database_authentication != null ? var.authentication_config.iam_database_authentication.enabled : null

  # Monitoring
  database_insights_mode                = var.database_insights
  performance_insights_enabled          = local.is_performance_insight_enabled
  performance_insights_retention_period = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.retention_period : null
  performance_insights_kms_key_id       = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.kms_key_id : null
  monitoring_interval                   = local.is_enhanced_monitoring_enabled ? var.monitoring_config.enable_enhanced_monitoring.interval : 0

  monitoring_role_arn = local.is_enhanced_monitoring_enabled ? (
    var.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? var.monitoring_config.enable_enhanced_monitoring.iam_role_arn : aws_iam_role.rds_enhanced_monitoring[0].arn
  ) : null

  # Additional Configuration
  # Database Options
  database_name                    = var.db_name
  db_cluster_parameter_group_name  = var.db_cluster_parameter_group
  db_instance_parameter_group_name = var.db_parameter_group

  # Backup
  backup_retention_period = var.enable_automated_backup != null ? var.enable_automated_backup.retention_period : 1
  preferred_backup_window = var.enable_automated_backup != null ? var.enable_automated_backup.window : null
  copy_tags_to_snapshot   = var.enable_automated_backup != null ? var.enable_automated_backup.copy_tags_to_snapshot : null

  # Encryption
  storage_encrypted = var.enable_encryption != null ? true : false
  kms_key_id        = var.enable_encryption != null ? var.enable_encryption.kms_key_arn : null

  # Log exports
  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports

  # Maintenance
  preferred_maintenance_window = var.maintenance_config != null ? var.maintenance_config.window : null

  # Delete protection
  deletion_protection = var.delete_protection_enabled

  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
