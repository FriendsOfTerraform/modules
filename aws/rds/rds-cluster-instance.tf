resource "aws_rds_cluster_instance" "cluster_instances" {
  for_each = var.cluster_instances

  cluster_identifier = aws_rds_cluster.aurora_cluster[0].id

  # Engine options
  engine         = var.engine.type
  engine_version = var.engine.version

  # Settings
  identifier = each.key

  # Instance Configuration
  instance_class = each.value.instance_class != null ? each.value.instance_class : var.instance_class

  # Connectivity
  availability_zone    = each.value.networking_config != null ? each.value.networking_config.availability_zone : null
  db_subnet_group_name = var.networking_config.db_subnet_group_name
  ca_cert_identifier   = var.networking_config.ca_cert_identifier

  # use the cluster_instance.networking_config.enable_public_access
  # if that is not specified, use the var.networking_config.enable_public_access
  publicly_accessible = each.value.networking_config != null ? (
    each.value.networking_config.enable_public_access != null ? (
      each.value.networking_config.enable_public_access
    ) : var.networking_config.enable_public_access != null ? var.networking_config.enable_public_access : null
  ) : var.networking_config.enable_public_access != null ? var.networking_config.enable_public_access : null

  # Monitoring
  performance_insights_enabled          = local.is_performance_insight_enabled ? true : each.value.monitoring_config.enable_performance_insight != null
  performance_insights_retention_period = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.retention_period : (each.value.monitoring_config.enable_performance_insight != null ? each.value.monitoring_config.enable_performance_insight.retention_period : null)
  performance_insights_kms_key_id       = local.is_performance_insight_enabled ? var.monitoring_config.enable_performance_insight.kms_key_id : (each.value.monitoring_config.enable_performance_insight != null ? each.value.monitoring_config.enable_performance_insight.kms_key_id : null)
  monitoring_interval                   = local.is_enhanced_monitoring_enabled ? var.monitoring_config.enable_enhanced_monitoring.interval : (each.value.monitoring_config.enable_enhanced_monitoring != null ? each.value.monitoring_config.enable_enhanced_monitoring.interval : 0)

  monitoring_role_arn = local.is_enhanced_monitoring_enabled ? (
    var.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? var.monitoring_config.enable_enhanced_monitoring.iam_role_arn : aws_iam_role.rds_enhanced_monitoring[0].arn
  ) : (each.value.monitoring_config.enable_enhanced_monitoring != null ? each.value.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? each.value.monitoring_config.enable_enhanced_monitoring.iam_role_arn : aws_iam_role.rds_enhanced_monitoring[0].arn : null)

  # Additional Configuration
  # Database Options
  promotion_tier          = each.value.failover_priority
  db_parameter_group_name = var.db_parameter_group

  # Backup
  //preferred_backup_window = var.enable_automated_backup != null ? var.enable_automated_backup.window : null
  copy_tags_to_snapshot = var.enable_automated_backup != null ? var.enable_automated_backup.copy_tags_to_snapshot : false

  # Maintenance
  auto_minor_version_upgrade   = each.value.maintenance_config.enable_auto_minor_version_upgrade != null ? each.value.maintenance_config.enable_auto_minor_version_upgrade : (var.maintenance_config != null ? var.maintenance_config.enable_auto_minor_version_upgrade : true)
  preferred_maintenance_window = each.value.maintenance_config.window != null ? each.value.maintenance_config.window : (var.maintenance_config != null ? var.maintenance_config.window : null)

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
