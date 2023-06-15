data "tls_certificate" "issuer_cert" {
  count = local.requires_service_account_to_iam_role_mappings ? 1 : 0

  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "iam_roles_to_service_accounts_provider" {
  count = local.requires_service_account_to_iam_role_mappings ? 1 : 0

  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.issuer_cert[0].certificates[0].sha1_fingerprint]
}
