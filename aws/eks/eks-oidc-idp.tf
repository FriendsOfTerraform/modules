resource "aws_eks_identity_provider_config" "oidc_idp" {
  count = var.oidc_identity_provider == null ? 0 : 1
  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_iam_role_policy_attachment.eks_cluster_role_attached_policy
  ]

  cluster_name = aws_eks_cluster.eks_cluster.id

  oidc {
    client_id                     = var.oidc_identity_provider.client_id
    groups_claim                  = length(split("_", var.oidc_identity_provider.groups_claim)) == 2 ? split("_", var.oidc_identity_provider.groups_claim)[1] : var.oidc_identity_provider.groups_claim
    groups_prefix                 = length(split("_", var.oidc_identity_provider.groups_claim)) == 2 ? split("_", var.oidc_identity_provider.groups_claim)[0] : null
    identity_provider_config_name = var.oidc_identity_provider.name
    issuer_url                    = var.oidc_identity_provider.issuer_url
    username_claim                = length(split("_", var.oidc_identity_provider.username_claim)) == 2 ? split("_", var.oidc_identity_provider.username_claim)[1] : var.oidc_identity_provider.username_claim
    username_prefix               = length(split("_", var.oidc_identity_provider.username_claim)) == 2 ? split("_", var.oidc_identity_provider.username_claim)[0] : null
  }

  # Setting the timeouts to higher number because it take at least 1 hour for the provider creation to complete
  timeouts {
    create = "90m"
    delete = "90m"
  }
}