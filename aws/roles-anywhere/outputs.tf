output "trust_anchor_arns" {
  value = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.arn }
}

output "trust_anchor_ids" {
  value = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.id }
}
