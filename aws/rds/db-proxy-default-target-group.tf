resource "aws_db_proxy_default_target_group" "default_target_groups" {
  for_each   = var.proxies
  depends_on = [aws_db_proxy.proxies]

  db_proxy_name = each.key

  connection_pool_config {
    connection_borrow_timeout    = split(" ", each.value.target_group_config.connection_borrow_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.target_group_config.connection_borrow_timeout)[1], "s")]
    init_query                   = each.value.target_group_config.initalization_query
    max_connections_percent      = each.value.target_group_config.connection_pool_maximum_connections
    max_idle_connections_percent = each.value.target_group_config.max_idle_connections_percent
    session_pinning_filters      = each.value.target_group_config.session_pinning_filters
  }
}

resource "aws_db_proxy_target" "default_targets" {
  for_each   = var.proxies
  depends_on = [aws_db_proxy.proxies]

  db_instance_identifier = local.is_aurora ? null : (var.deployment_option == "MultiAZCluster" ? null : aws_db_instance.db_instance[0].identifier)
  db_cluster_identifier  = local.is_aurora ? aws_rds_cluster.aurora_cluster[0].cluster_identifier : (var.deployment_option == "MultiAZCluster" ? aws_rds_cluster.multi_az_cluster[0].cluster_identifier : null)
  db_proxy_name          = each.key
  target_group_name      = aws_db_proxy_default_target_group.default_target_groups[each.key].name
}
