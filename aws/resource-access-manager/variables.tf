variable "name" {
  type        = string
  description = <<EOT
    The name of the resource share. All associated resources will also have their name prefixed with this value
    
    @since 1.0.0
  EOT
}

variable "accept_sharings" {
  type        = list(string)
  description = <<EOT
    List of share ARNs to accept sharing from
    
    @since 1.0.0
  EOT
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the resource share
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module
    
    @since 1.0.0
  EOT
  default     = {}
}

variable "allow_external_principals" {
  type        = bool
  description = <<EOT
    If enabled, you can share resources with any AWS accounts, roles, and users. If you are in an organization, you can also share with the entire organization or organizational units in that organization.
    
    @since 1.0.0
  EOT
  default     = false
}

variable "principals" {
  type        = list(string)
  description = <<EOT
    List of principals to grant access of the resources to. Valid values include: `the 12-digits AWS account ID, ARN of an AWS Organization, AWS Organization's OU, IAM role, IAM user, or a Service principal`.
    
    @since 1.0.0
  EOT
  default     = []
}

variable "resources" {
  type        = list(string)
  description = <<EOT
    List of ARNs of supported resources to share. Please refer to [this documentation][ram-shareable-resources] for a list of shareable resources.
    
    @link {ram-shareable-resources} https://docs.aws.amazon.com/ram/latest/userguide/shareable.html
    @since 1.0.0
  EOT
  default     = []
}
