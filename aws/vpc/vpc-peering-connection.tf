data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  peering_connection_requests = {
    for k, v in var.peering_connection_requests :
    k => {
      peer_vpc_id                     = v.peer_vpc_id
      additional_tags                 = v.additional_tags
      allow_remote_vpc_dns_resolution = v.allow_remote_vpc_dns_resolution
      peer_account_id                 = v.peer_account_id == null ? null : (v.peer_account_id == data.aws_caller_identity.current.account_id ? null : v.peer_account_id)
      peer_region                     = v.peer_region == null ? null : (v.peer_region == data.aws_region.current.name ? null : v.peer_region)
    }
  }
}

resource "aws_vpc_peering_connection" "peering_connection_requests" {
  for_each = local.peering_connection_requests

  peer_owner_id = each.value.peer_account_id
  peer_vpc_id   = each.value.peer_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = each.value.peer_account_id == null ? (each.value.peer_region == null ? true : false) : false
  peer_region   = each.value.peer_region

  dynamic "accepter" {
    for_each = each.value.peer_account_id == null ? (each.value.peer_region == null ? [1] : []) : []

    content {
      allow_remote_vpc_dns_resolution = each.value.allow_remote_vpc_dns_resolution
    }
  }

  dynamic "requester" {
    for_each = each.value.peer_account_id != null ? [1] : (each.value.peer_region != null ? [1] : [])

    content {
      allow_remote_vpc_dns_resolution = each.value.allow_remote_vpc_dns_resolution
    }
  }

  tags = merge(
    { Name = each.key },
    each.value.additional_tags,
    var.additional_tags_all
  )
}
