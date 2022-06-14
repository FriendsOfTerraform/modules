variable "azure" {
  type = object({
    resource_group_name = string
    location            = optional(string)
  })

  description = "Where the resources will be deployed on"
}

variable "cluster_admin_active_directory_group_ids" {
  type        = list(string)
  description = "List of AAD group IDs to be added in the Kubernetes cluster admin group"
}

variable "name" {
  type        = string
  description = "The name of the kubernetes cluster. All associated resources' names will also be prefixed by this value"
}

variable "node_pools" {
  type = map(object({
    desired_instances  = number
    vm_size            = string
    vnet_subnet_id     = string
    additional_tags    = optional(map(string))
    disk_size          = optional(number)
    kubernetes_version = optional(string)
    max_pods_per_node  = optional(number)
    max_instances      = optional(number)
    min_instances      = optional(number)
    zones              = optional(list(string))
  }))

  description = "Map of worker node pool in {node_pool_name = node_pool_config}"
}

variable "add_ons" {
  type = object({
    azure_key_vault_secrets_provider = optional(object({
      enabled                          = bool
      key_vault_name                   = string
      secret_rotation_interval_minutes = optional(number)
    }))

    azure_policy = optional(object({
      enabled = bool
    }))

    monitoring = optional(object({
      enabled        = bool
      retention_days = optional(number)
    }))
  })

  description = "Manages AKS add ons"
  default     = null
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

variable "apiserver_authorized_ip_ranges" {
  type        = list(string)
  description = "List of IP ranges to allow access to the API server"
  default     = ["0.0.0.0/0"]
}

variable "azure_container_registry_attachments" {
  type        = list(string)
  description = "List of ACR resource IDs to grant pull access to the cluster"
  default     = []
}

variable "enable_private_cluster" {
  type        = bool
  description = "Enables AKS private cluster"
  default     = false
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes, if unspecified, latest version will be used. Must be specified for auto-upgrade to work"
  default     = null
}

variable "networking_config" {
  type = object({
    plugin = string

    # common options
    kubernetes_service_address_range  = optional(string)
    kubernetes_dns_service_ip_address = optional(string)
    docker_bridge_address             = optional(string)

    # kubenet options
    kubernetes_pod_address_range = optional(string)
  })

  description = "Networking options for the Kubernetes control plane"
  default     = null
}

variable "user_assigned_managed_identity_ids" {
  type        = list(string)
  description = "List of managed identity IDs used by the cluster to manage azure resources"
  default     = []
}
