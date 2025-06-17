locals {
  time_table = {
    second = 1
    minute = 60
    hour   = 3600
  }
}

resource "aws_db_proxy" "proxies" {
  for_each = var.proxies

  name                   = each.key
  debug_logging          = each.value.activate_enhanced_logging
  engine_family          = upper(trimprefix(var.engine.type, "aurora-") == "postgres" ? "postgresql" : trimprefix(var.engine.type, "aurora-"))
  idle_client_timeout    = split(" ", each.value.idle_client_connection_timeout)[0] * local.time_table[trimsuffix(split(" ", each.value.idle_client_connection_timeout)[1], "s")]
  require_tls            = each.value.require_transport_layer_security
  role_arn               = each.value.iam_role_arn != null ? each.value.iam_role_arn : aws_iam_role.rds_proxy_secrets_reader_roles[each.key].arn
  vpc_security_group_ids = each.value.security_group_ids
  vpc_subnet_ids         = each.value.subnet_ids

  dynamic "auth" {
    for_each = each.value.authentications

    content {
      auth_scheme               = "SECRETS"
      secret_arn                = auth.key
      client_password_auth_type = auth.value.client_authentication_type
      iam_auth                  = auth.value.allow_iam_authentication ? "REQUIRED" : "DISABLED"
    }
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
