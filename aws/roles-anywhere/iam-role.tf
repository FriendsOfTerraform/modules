locals {
  roles = var.profiles != null ? (
    flatten([
      for profile_name, profile_value in var.profiles : [
        for role_name, role_value in profile_value.roles : {
          name                 = "${profile_name}-${role_value.trust_anchor_name}-${role_name}"
          attached_policy_arns = role_value.attached_policy_arns
          trust_anchor_name    = role_value.trust_anchor_name
          conditions           = role_value.conditions
          permissions_boundary = role_value.permissions_boundary
        }
      ]
    ])
  ) : []

  policy_attachments = var.profiles != null ? (
    flatten([
      for profile_name, profile_value in var.profiles : flatten([
        for role_name, role_value in profile_value.roles : [
          for policy in role_value.attached_policy_arns : {
            role_name  = "${profile_name}-${role_value.trust_anchor_name}-${role_name}"
            policy_arn = policy
          }
        ]
      ])
    ])
  ) : []
}

resource "aws_iam_role" "iam_roles" {
  count = length(local.roles)

  name                 = local.roles[count.index].name
  permissions_boundary = local.roles[count.index].permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rolesanywhere.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetSourceIdentity"
        ]
        Condition = merge(
          {
            ArnEquals = { "aws:SourceArn" = [aws_rolesanywhere_trust_anchor.trust_anchors[local.roles[count.index].trust_anchor_name].arn] }
          },
          local.roles[count.index].conditions != null ? ({ StringEquals = { for k, v in local.roles[count.index].conditions : "aws:PrincipalTag/${k}" => v } }) : {}
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachments" {
  count = length(local.policy_attachments)
  depends_on = [
    aws_iam_role.iam_roles
  ]

  role       = local.policy_attachments[count.index].role_name
  policy_arn = local.policy_attachments[count.index].policy_arn
}
