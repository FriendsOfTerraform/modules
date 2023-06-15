locals {
  common_tags = {
    managed-by = "Terraform"
  }

  addons_enabled = {
    vpc-cni            = local.addons_defined ? contains(keys(var.add_ons), "vpc-cni") : false
    aws-ebs-csi-driver = local.addons_defined ? contains(keys(var.add_ons), "aws-ebs-csi-driver") : false
    adot               = local.addons_defined ? contains(keys(var.add_ons), "adot") : false
  }

  # logic to determine if service account to iam role mapping is required
  addons_defined                                      = length(var.add_ons) > 0
  custom_service_account_to_iam_role_mappings_defined = length(var.service_account_to_iam_role_mappings) > 0
  requires_service_account_to_iam_role_mappings       = local.custom_service_account_to_iam_role_mappings_defined ? true : contains(values(local.addons_enabled), true)

  # merge the required service account to iam role mapping for the addons and whatever end user defined
  addons_service_account_to_iam_role_mappings = {
    vpc-cni            = { "kube-system/aws-node" = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"] }
    aws-ebs-csi-driver = { "kube-system/ebs-csi-controller-sa" = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"] }
    adot = {
      "default/adot-collector" = [
        "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
        "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      ]
    }
  }

  service_account_to_iam_role_mappings = merge({
    for addon, role in local.addons_service_account_to_iam_role_mappings :
    keys(role)[0] => values(role)[0] if local.addons_enabled[addon]
  }, var.service_account_to_iam_role_mappings)
}
