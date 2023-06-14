variable "name" {
  type        = string
  description = "The name of the kubernetes cluster. All associated resources' names will also be prefixed by this value"
}

variable "node_groups" {
  type = map(object({
    desired_instances                       = number
    subnet_ids                              = list(string)
    additional_tags                         = optional(map(string))
    ami_type                                = optional(string)
    ami_release_version                     = optional(string)
    capacity_type                           = optional(string, "ON_DEMAND")
    disk_size                               = optional(number)
    ignores_pod_disruption_budget           = optional(bool, false)
    instance_type                           = optional(string, "t3.medium")
    kubernetes_labels                       = optional(map(string))
    kubernetes_taints                       = optional(map(string))
    kubernetes_version                      = optional(string)
    max_instances                           = optional(number)
    max_unavailable_instances_during_update = optional(string)
    min_instances                           = optional(number)
  }))
  description = "Map of worker node groups in {node_group_name = node_group_config}"
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = optional(list(string))
  })
  description = "VPC configuration for the kubernetes cluster"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the kubernetes cluster"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "add_ons" {
  type = map(object({
    additional_tags             = optional(map(string))
    configuration               = optional(string)
    iam_role_arn                = optional(string)
    preserve                    = optional(bool)
    resolve_conflicts_on_create = optional(string)
    resolve_conflicts_on_update = optional(string)
    version                     = optional(string)
  }))
  description = "Manages supported EKS add ons"
  default     = {}
}

variable "apiserver_allowed_cidrs" {
  type        = list(string)
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint"
  default     = ["0.0.0.0/0"]
}

variable "enable_apiserver_public_endpoint" {
  type        = bool
  description = "Enable the EKS public endpoint for external API request to the cluster"
  default     = false
}

variable "enable_cluster_log_types" {
  type        = list(string)
  description = "List of the desired control plane logging to enable"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "envelope_encryption" {
  type        = object({ kms_key_arn = string })
  description = "Turn on envelope encryption of Kubernetes secrets using KMS"
  default     = null
}

variable "kubernetes_networking_config" {
  type = object({
    kubernetes_service_address_range = optional(string)
    ip_family                        = optional(string)
  })
  description = "Configures various Kubernetes networking options"
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes, if unspecified, latest version will be used. Must be specified for auto-upgrade to work"
  default     = null
}

variable "service_account_to_iam_role_mappings" {
  type        = map(list(string))
  description = "Map a service account or a namespace to an IAM role that is associated with a list of policies."
  default     = {}
}
