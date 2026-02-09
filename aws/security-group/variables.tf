variable "name" {
  type        = string
  description = <<EOT
    The name of the security group. All associated resources will also have their name prefixed with this value
    
    @since 1.0.0
  EOT
}

variable "vpc_id" {
  type        = string
  description = ""
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the security group
    
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

variable "description" {
  type        = string
  description = <<EOT
    Description of the security group
    
    @since 1.0.0
  EOT
  default     = null
}

variable "egress_rules" {
  type = map(object({
    /// A list of destinations this rule applies to. Destinations can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs
    /// 
    /// @since 1.0.0
    destinations = list(string)
    /// Additional tags for the egress rule
    /// 
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
    /// Description for the egress rule
    /// 
    /// @since 1.0.0
    description = optional(string)
  }))
  description = <<EOT
    Configures multiple [egress rules][security-group-rules].
    
    @example "Basic Usage" #basic-usage
    @link {security-group-rules} https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
    @since 1.0.0
  EOT
  default     = {}
}

variable "ingress_rules" {
  type = map(object({
    /// A list of sources this rule applies to. Sources can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs
    /// 
    /// @since 1.0.0
    sources = list(string)
    /// Additional tags for the ingress rule
    /// 
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
    /// Description for the ingress rule
    /// 
    /// @since 1.0.0
    description = optional(string)
  }))
  description = <<EOT
    Configures multiple [ingress rules][security-group-rules].
    
    @example "Basic Usage" #basic-usage
    @link {security-group-rules} https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
    @since 1.0.0
  EOT
  default     = {}
}
