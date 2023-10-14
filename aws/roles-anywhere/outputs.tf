output "profile_arns" {
  value = { for k, v in aws_rolesanywhere_profile.profiles : k => v.arn }
}

output "profile_ids" {
  value = { for k, v in aws_rolesanywhere_profile.profiles : k => v.id }
}

output "trust_anchor_arns" {
  value = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.arn }
}

output "trust_anchor_ids" {
  value = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.id }
}
