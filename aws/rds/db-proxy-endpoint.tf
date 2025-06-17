locals {
  proxy_endpoints_to_create = flatten([
    for k, v in var.proxies : [
      for endpoint_name, endpoint_value in v.additional_endpoints : {
        proxy_name          = k
        proxy_endpoint_name = endpoint_name
        security_group_ids  = endpoint_value.security_group_ids != null ? endpoint_value.security_group_ids : v.security_group_ids
        subnet_ids          = endpoint_value.subnet_ids != null ? endpoint_value.subnet_ids : v.subnet_ids
        target_role         = endpoint_value.target_role
      }
    ] if v.additional_endpoints != null
  ])
}

resource "aws_db_proxy_endpoint" "additional_proxy_endpoints" {
  for_each   = tomap({ for endpoint in local.proxy_endpoints_to_create : "${endpoint.proxy_name}/${endpoint.proxy_endpoint_name}" => endpoint })
  depends_on = [aws_db_proxy.proxies]

  db_proxy_name          = each.value.proxy_name
  db_proxy_endpoint_name = each.value.proxy_endpoint_name
  vpc_subnet_ids         = each.value.subnet_ids
  vpc_security_group_ids = each.value.security_group_ids
  target_role            = each.value.target_role
}
