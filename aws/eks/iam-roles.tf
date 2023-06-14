locals {
  assume_role_policy = "${path.module}/iam-policies/service-assume-role-policy.json"

  eks_node_instance_role_attached_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  service_account_roles_policy_attachments = flatten([
    for service_account, policies in local.service_account_to_iam_role_mappings : [
      for policy in policies : {
        service_account = service_account
        policy          = policy
      }
    ]
  ])
}

# IAM role that Kubernetes can assume to create AWS resources. For example, when a load balancer is created, Kubernetes
#     assumes the role to create an ELB load balancer in your account.
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.name}-cluster-role"
  description        = "Used by the ${var.name} EKS cluster to manage associated AWS resources"
  assume_role_policy = templatefile(local.assume_role_policy, { aws_service = "eks.amazonaws.com" })

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attached_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role that provides permissions for the worker nodes to connect to EKS for registration
resource "aws_iam_role" "eks_node_instance_role" {
  name               = "${var.name}-node-instance-role"
  description        = "Used by the ${var.name} EKS cluster to manage node groups"
  assume_role_policy = templatefile(local.assume_role_policy, { aws_service = "ec2.amazonaws.com" })

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role_policy_attachment" "eks_node_instance_role_attached_policies" {
  for_each = toset(local.eks_node_instance_role_attached_policies)

  role       = aws_iam_role.eks_node_instance_role.name
  policy_arn = each.key
}

# IAM Role for service account mappings
resource "aws_iam_role" "service_account_roles" {
  for_each = local.service_account_to_iam_role_mappings

  name = "${aws_eks_cluster.eks_cluster.id}-${replace(each.key, "/", "-")}"
  assume_role_policy = templatefile("${path.module}/iam-policies/oidc-trust-policy.json", {
    oidc_provider_arn               = aws_iam_openid_connect_provider.iam_roles_to_service_accounts_provider[0].arn,
    oidc_provider_name              = join("/", slice(split("/", aws_iam_openid_connect_provider.iam_roles_to_service_accounts_provider[0].arn), 1, 4)),
    kubernetes_namespace            = split("/", each.key)[0],
    kubernetes_service_account_name = length(split("/", each.key)) > 1 ? split("/", each.key)[1] : "*"
  })
}

resource "aws_iam_role_policy_attachment" "service_account_roles_policy_attachments" {
  count = length(local.service_account_roles_policy_attachments)

  role       = aws_iam_role.service_account_roles[local.service_account_roles_policy_attachments[count.index].service_account].name
  policy_arn = local.service_account_roles_policy_attachments[count.index].policy
}
