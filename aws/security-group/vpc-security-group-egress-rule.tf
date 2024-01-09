locals {
  egress_rules = flatten([
    for port_range, egress in var.egress_rules : flatten([
      for destination in egress.destinations :
      {
        cidr_ipv4                    = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", destination)) > 0 ? destination : null
        cidr_ipv6                    = length(regexall("^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\\/(12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))$", destination)) > 0 ? destination : null
        prefix_list_id               = length(regexall("pl-[0-9a-f]{8}", destination)) > 0 ? destination : null
        referenced_security_group_id = length(regexall("sg-[0-9a-f]{17}$", destination)) > 0 ? destination : null
        description                  = egress.description
        ip_protocol                  = length(split("/", port_range)) > 1 ? split("/", port_range)[1] : trimprefix(port_range, "all_")

        # Check to see if the protocol is within one of the all port range group, if so, starting port should be 0
        from_port = contains(local.icmp_port_range, port_range) ? -1 : contains(local.all_port_range, port_range) ? 0 : (
          # otherwise, use the specified starting port number
          length(regexall(".*-.*", split("/", port_range)[0])) > 0 ? (
            split("-", split("/", port_range)[0])[0]
          ) : split("/", port_range)[0]
        )

        # Check to see if the protocol is within one of the all port range group, if so, ending port should be 65535
        to_port = contains(local.icmp_port_range, port_range) ? -1 : contains(local.all_port_range, port_range) ? 65535 : (
          # otherwise, use the specified ending port number
          length(regexall(".*-.*", split("/", port_range)[0])) > 0 ? (
            split("-", split("/", port_range)[0])[1]
          ) : split("/", port_range)[0]
        )

        tags = merge(
          { Name = port_range },
          local.common_tags,
          egress.additional_tags,
          var.additional_tags_all
        )
      }
    ])
  ])
}

resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  count = length(local.egress_rules)

  security_group_id            = aws_security_group.security_group.id
  cidr_ipv4                    = local.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = local.egress_rules[count.index].cidr_ipv6
  description                  = local.egress_rules[count.index].description
  from_port                    = local.egress_rules[count.index].from_port
  ip_protocol                  = local.egress_rules[count.index].ip_protocol
  prefix_list_id               = local.egress_rules[count.index].prefix_list_id
  referenced_security_group_id = local.egress_rules[count.index].referenced_security_group_id
  tags                         = local.egress_rules[count.index].tags
  to_port                      = local.egress_rules[count.index].to_port
}
