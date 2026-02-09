variable "azure" {
  type = object({
    /// The name of an Azure resource group where the cluster will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location            = optional(string, null)
  })

  description = <<EOT
    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    @since 0.0.1
  EOT
}

variable "cluster_admin_active_directory_group_ids" {
  type        = list(string)
  description = <<EOT
    List of Azure active directory group IDs that will be added as the `cluster admins` on the cluster

    @since 0.0.1
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the Kubernetes cluster. This will also be used as a prefix to all associating resources' names.

    @since 0.0.1
  EOT
}

variable "node_pools" {
  type = map(object({
    /// The initial number of nodes for this node pool
    ///
    /// @since 0.0.1
    desired_instances  = number
    /// [Azure VM size][azure-vm-size]. Also see [Azure VM Naming Convention][azure-vm-naming-convention]
    ///
    /// @link {azure-vm-size} https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
    /// @link {azure-vm-naming-convention} https://docs.microsoft.com/en-us/azure/virtual-machines/vm-naming-conventions
    /// @since 0.0.1
    vm_size            = string
    /// The ID of the subnet where new nodes from this pool will be deployed into
    ///
    /// @since 0.0.1
    vnet_subnet_id     = string
    /// Additional tags for this node pool
    ///
    /// @since 0.0.1
    additional_tags    = optional(map(string), {})
    /// The size of OS disk in GB, defaults to `512 GB`
    ///
    /// @since 0.0.1
    disk_size          = optional(number, 512)
    /// The Kubernetes version for the node pool, defaults to the latest version. This value must be specified for cluster upgrade to work.
    ///
    /// @since 0.0.1
    kubernetes_version = optional(string, null)
    /// The max number of pods that can be deployed on each node.
    ///
    /// @since 0.0.1
    max_pods_per_node  = optional(number, 30)
    /// The maximum number of nodes this pool can scale up to. `cluster auto scaling` will be enabled if both this and `min_instances` are specified.
    ///
    /// @since 0.0.1
    max_instances      = optional(number, null)
    /// The minimum number of nodes this pool can scale down to. `cluster auto scaling` will be enabled if both this and `man_instances` are specified.
    ///
    /// @since 0.0.1
    min_instances      = optional(number, null)
    /// A list of availability zones the nodes should be deployed onto
    ///
    /// @since 0.0.1
    zones              = optional(list(string), null)
  }))

  description = <<EOT
    Configures the cluster's node pools. In `{node_pool_name = {configurations}}` format

    ```terraform
    default = {
      vm_size            = "Standard_DS2_v2"
      vnet_subnet_id     = module.aks_vnet.subnet_ids["default-node-pool"] # referencing the default-node-pool subnet in the aks_vnet module
      desired_instances  = 2
      kubernetes_version = local.kubernetes_version
    }
    ```

    @since 0.0.1
  EOT
}

variable "add_ons" {
  type = object({
    /// Configures the [Azure Key Vault Provider][azure-key-vault-provider] add-on
    ///
    /// @link {azure-key-vault-provider} https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
    /// @since 0.0.1
    azure_key_vault_secrets_provider = optional(object({
      /// Enables this add-on
      ///
      /// @since 0.0.1
      enabled                          = bool
      /// Name of the Azure Key Vault to allow this cluster to retrieve secrets from
      ///
      /// @since 0.0.1
      key_vault_name                   = string
      /// The interval in minutes that the secrets in the cluster will be refreshed
      ///
      /// @since 0.0.1
      secret_rotation_interval_minutes = optional(number, 2)
    }))

    /// Configures the [Azure Policy][azure-policy] add-on
    ///
    /// @link {azure-policy} https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
    /// @since 0.0.1
    azure_policy = optional(object({
      /// Enables this add-on
      ///
      /// @since 0.0.1
      enabled = bool
    }))

    /// Configures the [Container Insights][container-insights] add-on
    ///
    /// @link {container-insights} https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
    /// @since 0.0.1
    monitoring = optional(object({
      /// Enables this add-on
      ///
      /// @since 0.0.1
      enabled        = bool
      /// How long in days the logs will be retained
      ///
      /// @since 0.0.1
      retention_days = optional(number, 60)
    }))
  })

  description = <<EOT
    Manages [AKS add-ons][aks-add-ons]. The following list of add-ons are currently supported:

    - [Azure Key Vault Provider][azure-key-vault-provider]
    - [Azure Policy][azure-policy]
    - [Container Insights][container-insights]

    ```terraform
    add_ons = {
      azure_key_vault_secrets_provider = {
        enabled = true
        key_vault_name = "demo-keyvault"
      }

      azure_policy = {
        enabled = true
      }

      monitoring = {
        enabled = true
        retention_days = 180
      }
    }
    ```

    @link {aks-add-ons} https://docs.microsoft.com/en-us/azure/aks/integrations#add-ons
    @link {azure-key-vault-provider} https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
    @link {azure-policy} https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
    @link {container-insights} https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
    @since 0.0.1
  EOT
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the Kubernetes cluster

    @since 0.0.1
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 0.0.1
  EOT
  default     = {}
}

variable "apiserver_authorized_ip_ranges" {
  type        = list(string)
  description = <<EOT
    List of IP addresses that are allowed to communicate with the API server. This option is only available if `enable_private_cluster = false`

    @since 0.0.1
  EOT
  default     = ["0.0.0.0/0"]
}

variable "azure_container_registry_attachments" {
  type        = list(string)
  description = <<EOT
    List of ACR resource IDs to grant pull access to the cluster's kubelet identity. Please refer to [this document][acr-integration] for more information

    @link {acr-integration} https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli
    @since 0.0.1
  EOT
  default     = []
}

variable "enable_private_cluster" {
  type        = bool
  description = <<EOT
    Enables [private AKS cluster][private-aks-cluster], where the control plane can only be accessed internally

    @link {private-aks-cluster} https://docs.microsoft.com/en-us/azure/aks/private-clusters
    @since 0.0.1
  EOT
  default     = false
}

variable "kubernetes_version" {
  type        = string
  description = <<EOT
    The Kubernetes version for the control plane. The `latest` version is used if unspecified. This value must be specified to enable cluster upgrade.

    @since 0.0.1
  EOT
  default     = null
}

variable "networking_config" {
  type = object({
    /// The Kubernetes network plugin to use.
    ///
    /// @enum kubenet|azure
    /// @since 0.0.1
    plugin = string

    # common options
    /// The Network Range used by the Kubernetes service
    ///
    /// @since 0.0.1
    kubernetes_service_address_range  = optional(string, "10.0.0.0/16")
    /// IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
    ///
    /// @since 0.0.1
    kubernetes_dns_service_ip_address = optional(string, "10.0.0.10")
    /// IP address (in CIDR notation) used as the Docker bridge IP address on nodes
    ///
    /// @since 0.0.1
    docker_bridge_address             = optional(string, "172.17.0.1/16")

    # kubenet options
    /// The CIDR to use for pod IP addresses. This field can only be set when `plugin = kubenet`
    ///
    /// @since 0.0.1
    kubernetes_pod_address_range = optional(string, "10.244.0.0/16")
  })

  description = <<EOT
    Networking options for the Kubernetes control plane

    ```terraform
    networking_config = {
      plugin = "kubenet"
    }
    ```

    @since 0.0.1
  EOT
  default     = null
}

variable "user_assigned_managed_identity_ids" {
  type        = list(string)
  description = <<EOT
    List of managed identity IDs used by the cluster to manage azure resources

    @since 0.0.1
  EOT
  default     = []
}
