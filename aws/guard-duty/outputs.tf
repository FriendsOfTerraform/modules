output "detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.guardduty_detector.id
}

output "detector_arn" {
  description = "The ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.guardduty_detector.arn
}

output "detector_account_id" {
  description = "The AWS account ID of the GuardDuty detector"
  value       = aws_guardduty_detector.guardduty_detector.account_id
}

output "malware_protection_s3_role_arns" {
  description = "Map of S3 bucket names to their GuardDuty malware protection IAM role ARNs"
  value = {
    for bucket_name, role in aws_iam_role.malware_protection_s3_roles :
    bucket_name => role.arn
  }
}

output "malware_protection_s3_role_ids" {
  description = "Map of S3 bucket names to their GuardDuty malware protection IAM role IDs"
  value = {
    for bucket_name, role in aws_iam_role.malware_protection_s3_roles :
    bucket_name => role.id
  }
}

output "malware_protection_plan_ids" {
  description = "Map of S3 bucket names to their GuardDuty malware protection plan IDs"
  value = {
    for bucket_name, plan in aws_guardduty_malware_protection_plan.malware_protections_s3 :
    bucket_name => plan.id
  }
}

output "threat_intellset_ids" {
  description = "Map of threat intelligence set IDs"
  value = {
    for name, set in aws_guardduty_threatintelset.threat_ip_lists :
    name => set.id
  }
}

output "ipset_ids" {
  description = "Map of trusted IP set IDs"
  value = {
    for name, set in aws_guardduty_ipset.trusted_ip_lists :
    name => set.id
  }
}

output "filter_ids" {
  description = "Map of GuardDuty filter IDs for suppression rules"
  value = {
    for name, filter in aws_guardduty_filter.suppression_rules :
    name => filter.id
  }
}

output "member_account_ids" {
  description = "Map of member account IDs to their relationship IDs"
  value = {
    for account_id, member in aws_guardduty_member.members :
    account_id => member.id
  }
}

output "publishing_destination_id" {
  description = "The ID of the GuardDuty publishing destination (if configured)"
  value       = try(aws_guardduty_publishing_destination.findings_export_options[0].id, null)
}
