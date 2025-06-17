resource "aws_db_instance" "db_instance" {
  count = local.is_aurora ? 0 : (var.deployment_option == "MultiAZCluster" ? 0 : 1)

  apply_immediately = var.apply_immediately

  # Engine options
  engine         = var.engine.type
  engine_version = var.engine.version

  # Deployment options
  multi_az = var.deployment_option == "MultiAZInstance"

  # Settings
  identifier = var.name

  # Credentials Settings
  username                      = var.authentication_config.db_master_account.username
  password                      = var.authentication_config.db_master_account.password
  manage_master_user_password   = var.authentication_config.db_master_account.manage_password_in_secrets_manager
  master_user_secret_kms_key_id = var.authentication_config.db_master_account.customer_kms_key_id

  # Instance Configuration
  instance_class = var.instance_class

  # Storage
  storage_type          = var.storage_config != null ? var.storage_config.type : null
  allocated_storage     = var.storage_config != null ? var.storage_config.allocated_storage : null
  iops                  = var.storage_config != null ? var.storage_config.provisioned_iops : null
  max_allocated_storage = var.storage_config != null ? var.storage_config.max_allocated_storage : null
  storage_throughput    = var.storage_config != null ? var.storage_config.storage_throughput : null

  # Connectivity
  network_type           = var.networking_config.enable_ipv6 ? "DUAL" : "IPV4"
  db_subnet_group_name   = var.networking_config.db_subnet_group_name
  publicly_accessible    = var.networking_config.enable_public_access
  vpc_security_group_ids = var.networking_config.security_group_ids
  availability_zone      = var.networking_config.availability_zone
  ca_cert_identifier     = var.networking_config.ca_cert_identifier
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
  db_name              = var.db_name
  parameter_group_name = var.db_parameter_group
  option_group_name    = var.option_group

  # Backup
  backup_retention_period = var.enable_automated_backup != null ? var.enable_automated_backup.retention_period : 0
  backup_window           = var.enable_automated_backup != null ? var.enable_automated_backup.window : null
  copy_tags_to_snapshot   = var.enable_automated_backup != null ? var.enable_automated_backup.copy_tags_to_snapshot : false

  # Encryption
  storage_encrypted = var.enable_encryption != null ? true : false
  kms_key_id        = var.enable_encryption != null ? var.enable_encryption.kms_key_arn : null

  # Log exports
  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports

  # Maintenance
  auto_minor_version_upgrade = var.maintenance_config != null ? var.maintenance_config.enable_auto_minor_version_upgrade : true
  maintenance_window         = var.maintenance_config != null ? var.maintenance_config.window : null

  # Delete protection
  deletion_protection = var.delete_protection_enabled

  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
