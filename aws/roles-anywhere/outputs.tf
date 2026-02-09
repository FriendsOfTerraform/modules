output "profile_arns" {
  description = <<EOT
    Map of ARNs of all profiles
    
    @type map(string)
    @since 1.0.0
  EOT
  value       = { for k, v in aws_rolesanywhere_profile.profiles : k => v.arn }
}

output "profile_ids" {
  description = <<EOT
    Map of IDs of all profiles
    
    @type map(string)
    @since 1.0.0
  EOT
  value       = { for k, v in aws_rolesanywhere_profile.profiles : k => v.id }
}

output "trust_anchor_arns" {
  description = <<EOT
    Map of ARNs of all trust anchors
    
    @type map(string)
    @since 1.0.0
  EOT
  value       = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.arn }
}

output "trust_anchor_ids" {
  description = <<EOT
    Map of IDs of all trust anchors
    
    @type map(string)
    @since 1.0.0
  EOT
  value       = { for k, v in aws_rolesanywhere_trust_anchor.trust_anchors : k => v.id }
}
