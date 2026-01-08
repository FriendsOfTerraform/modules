locals {
  health_checks = {
    for k, v in local.records :
    k => {
      enabled                    = v.health_check.enabled
      invert_health_check_status = v.health_check.invert_health_check_status

      ######################################
      ######### Calculated Check ###########
      ######################################
      is_calculated_check                       = v.health_check.calculated_check != null
      calculated_check_health_checks_to_monitor = v.health_check.calculated_check != null ? v.health_check.calculated_check.health_checks_to_monitor : null

      calculated_check_healthy_threshold = v.health_check.calculated_check != null ? (
        # defaults to the length of inputted health checks (all health checks must be healthy)
        v.health_check.calculated_check.healthy_threshold != null ? v.health_check.calculated_check.healthy_threshold : length(v.health_check.calculated_check.health_checks_to_monitor)
      ) : null

      ######################################
      ##### CloudWatch Alarm Check #########
      ######################################
      is_cloudwatch_alarm_check                              = v.health_check.cloudwatch_alarm_check != null
      cloudwatch_alarm_check_alarm_name                      = v.health_check.cloudwatch_alarm_check != null ? v.health_check.cloudwatch_alarm_check.alarm_name : null
      cloudwatch_alarm_check_insufficient_data_health_status = v.health_check.cloudwatch_alarm_check != null ? v.health_check.cloudwatch_alarm_check.insufficient_data_health_status : null

      # defaults to current region if one is not specified
      cloudwatch_alarm_check_alarm_region = v.health_check.cloudwatch_alarm_check != null ? (
        v.health_check.cloudwatch_alarm_check.alarm_region != null ? v.health_check.cloudwatch_alarm_check.alarm_region : data.aws_region.current.region
      ) : null

      ######################################
      ######### Endpoint Check #############
      ######################################
      is_endpoint_check                    = v.health_check.endpoint_check != null
      endpoint_check_protocol              = v.health_check.endpoint_check != null ? upper(regex("https?|tcp", v.health_check.endpoint_check.url)) : null
      endpoint_check_enable_latency_graphs = v.health_check.endpoint_check != null ? v.health_check.endpoint_check.enable_latency_graphs : null
      endpoint_check_failure_threshold     = v.health_check.endpoint_check != null ? v.health_check.endpoint_check.failure_threshold : null
      endpoint_check_regions               = v.health_check.endpoint_check != null ? v.health_check.endpoint_check.regions : null
      endpoint_check_request_interval      = v.health_check.endpoint_check != null ? v.health_check.endpoint_check.request_interval : null
      endpoint_check_search_string         = v.health_check.endpoint_check != null ? v.health_check.endpoint_check.search_string : null

      endpoint_check_ip_address = v.health_check.endpoint_check != null ? (
        length(regexall("(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])", v.health_check.endpoint_check.url)) > 0 ? (
          split(":", split("/", v.health_check.endpoint_check.url)[2])[0]
          ) : length(regexall("((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))", v.health_check.endpoint_check.url)) > 0 ? (
          trimprefix(split("]", split("/", v.health_check.endpoint_check.url)[2])[0], "[")
        ) : null
      ) : null

      endpoint_check_fqdn = v.health_check.endpoint_check != null ? (
        length(regexall("(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])", v.health_check.endpoint_check.url)) < 1 ? (
          length(regexall("((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))", v.health_check.endpoint_check.url)) < 1 ? (
            split(":", split("/", v.health_check.endpoint_check.url)[2])[0]
          ) : v.health_check.endpoint_check.hostname
        ) : v.health_check.endpoint_check.hostname
      ) : null

      endpoint_check_port = v.health_check.endpoint_check != null ? (
        # case ipv6
        length(regexall("((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))", v.health_check.endpoint_check.url)) > 0 ? (
          # If a port number is specified, use it. Otherwise, use the default port number
          length(split("]", split("/", v.health_check.endpoint_check.url)[2])) > 1 ? trimprefix(split("]", split("/", v.health_check.endpoint_check.url)[2])[1], ":") : regex("https?", v.health_check.endpoint_check.url) == "http" ? 80 : 443
          # case ipv4 or domain name
          ) : length(split(":", split("/", v.health_check.endpoint_check.url)[2])) > 1 ? (
          split(":", split("/", v.health_check.endpoint_check.url)[2])[1]
          # use default port number if a port number is not specified
        ) : regex("https?", v.health_check.endpoint_check.url) == "http" ? 80 : 443
      ) : null

      endpoint_check_resource_path = v.health_check.endpoint_check != null ? (
        regex("https?|tcp", v.health_check.endpoint_check.url) != "tcp" ? (
          "/${join("/", [for i in range(3, length(split("/", v.health_check.endpoint_check.url))) : split("/", v.health_check.endpoint_check.url)[i]])}"
        ) : null
      ) : null
    } if v.health_check != null
  }
}

# TODOs - Give Default name to health_check
resource "aws_route53_health_check" "health_checks" {
  for_each = local.health_checks

  type = each.value.is_endpoint_check ? (
    each.value.endpoint_check_search_string != null ? "${each.value.endpoint_check_protocol}_STR_MATCH" : each.value.endpoint_check_protocol
  ) : each.value.is_calculated_check ? "CALCULATED" : "CLOUDWATCH_METRIC"

  tags = merge(
    {
      "hosted-zone" = var.domain_name
      "record"      = each.key
    },
    local.common_tags,
    var.additional_tags_all
  )

  disabled           = !each.value.enabled
  invert_healthcheck = each.value.invert_health_check_status

  # calculated health check
  child_healthchecks     = each.value.calculated_check_health_checks_to_monitor
  child_health_threshold = each.value.calculated_check_healthy_threshold

  # cloudwatch alarm check
  cloudwatch_alarm_name           = each.value.cloudwatch_alarm_check_alarm_name
  cloudwatch_alarm_region         = each.value.cloudwatch_alarm_check_alarm_region
  insufficient_data_health_status = each.value.cloudwatch_alarm_check_insufficient_data_health_status

  # endpoint health check
  failure_threshold = each.value.endpoint_check_failure_threshold
  fqdn              = each.value.endpoint_check_fqdn
  ip_address        = each.value.endpoint_check_ip_address
  measure_latency   = each.value.endpoint_check_enable_latency_graphs
  port              = each.value.endpoint_check_port
  regions           = each.value.endpoint_check_regions
  request_interval  = each.value.endpoint_check_request_interval
  resource_path     = each.value.endpoint_check_resource_path
  search_string     = each.value.endpoint_check_search_string
}
