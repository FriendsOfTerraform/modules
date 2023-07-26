resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enable_cluster_log_types

  dynamic "encryption_config" {
    for_each = var.envelope_encryption != null ? [1] : []

    content {
      provider { key_arn = var.envelope_encryption.kms_key_arn }
      resources = ["secrets"]
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.kubernetes_networking_config != null ? [1] : []

    content {
      service_ipv4_cidr = var.kubernetes_networking_config.kubernetes_service_address_range
      ip_family         = var.kubernetes_networking_config.ip_family
    }
  }

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = var.enable_apiserver_public_endpoint
    public_access_cidrs     = var.enable_apiserver_public_endpoint ? var.apiserver_allowed_cidrs : null
    security_group_ids      = concat([aws_security_group.control_plane_security_group.id], var.vpc_config.security_group_ids)
    subnet_ids              = var.vpc_config.subnet_ids
  }
}