# Kubernetes Service Module

This module will create and configure an [Azure Kubernetes Cluster][azure-kubernetes-service] with additional node pools

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

This example creates an AKS cluster with a `default node pool` and a `secondary node pool`. The `secondary node pool` will be configured with cluster auto scaling. Because Azure CNI requires an existing vnet, we will create one here as well.

```terraform
module "aks_vnet" {
  source = {{PLACE_HOLDER}}

  azure               = { resource_group_name = "sandbox" }
  name                = "aks-vnet"
  cidr_blocks         = ["172.16.0.0/20"] # 4094 IP addresses
  additional_tags_all = { created-by = "Peter Sin" }

  subnets = {
    default-node-pool   = { cidr_block = "172.16.0.0/21" } # subnet for default node pool, 2048 addresses
    secondary-node-pool = { cidr_block = "172.16.8.0/21" } # subnet for secondary node pool, 2048 addresses
  }
}

locals {
  kubernetes_version = "1.22.6"
}

module "aks_cluster" {
  source = {{PLACE_HOLDER}}

  azure = { resource_group_name = "sandbox" }

  # These AAD groups will be added to the Kubernetes cluster admins group
  cluster_admin_active_directory_group_ids = [ "6bccaaa6-4f66-xxxx-xxxx-xxxxxxxx" ]

  name = "aks-demo"

  node_pools = {
    default = {
      vm_size            = "Standard_DS2_v2"
      vnet_subnet_id     = module.aks_vnet.subnet_ids["default-node-pool"] # referencing the default-node-pool subnet in the aks_vnet module
      desired_instances  = 2
      kubernetes_version = local.kubernetes_version
    }
    secondary = {
      vm_size            = "Standard_DS2_v2"
      vnet_subnet_id     = module.aks_vnet.subnet_ids["secondary-node-pool"]
      desired_instances  = 1

      # cluster auto scaling is turned on when both min_instances and max_instances are specified
      min_instances      = 1
      max_instances      = 3
      kubernetes_version = local.kubernetes_version
    }
  }

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

  additional_tags_all = {
    created-by = "Peter Sin"
  }

  apiserver_authorized_ip_ranges = ["0.0.0.0/0"]
  kubernetes_version             = local.kubernetes_version
}
```

## Argument Reference

### Mandatory

- (object) **`azure`** _[since v0.0.1]_

    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    - (string) **`resource_group_name`** _[since v0.0.1]_

        The name of an Azure resource group where the cluster will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.

- (string) **`cluster_admin_active_directory_group_ids`** _[since v0.0.1]_

    List of Azure active directory group IDs that will be added as the `cluster admins` on the cluster

- (string) **`name`** _[since v0.0.1]_

    The name of the Kubernetes cluster. This will also be used as a prefix to all associating resources' names.

- (map(object)) **`node_pools`** _[since v0.0.1]_

    Configures the cluster's node pools. In `{node_pool_name = {configurations}}` format

    ```terraform
    default = {
      vm_size            = "Standard_DS2_v2"
      vnet_subnet_id     = module.aks_vnet.subnet_ids["default-node-pool"] # referencing the default-node-pool subnet in the aks_vnet module
      desired_instances  = 2
      kubernetes_version = local.kubernetes_version
    }
    ```

    - (number) **`desired_instances`** _[since v0.0.1]_

        The initial number of nodes for this node pool

    - (string) **`vm_size`** _[since v0.0.1]_

        [Azure VM size][azure-vm-size]. Also see [Azure VM Naming Convention][azure-vm-naming-convention]

    - (string) **`vnet_subnet_id`** _[since v0.0.1]_

        The ID of the subnet where new nodes from this pool will be deployed into

    - (map(string)) **`additional_tags = null`** _[since v0.0.1]_

        Additional tags for this node pool

    - (number) **`disk_size = 512`** _[since v0.0.1]_

        The size of OS disk in GB, defaults to `512 GB`

    - (string) **`kubernetes_version = null`** _[since v0.0.1]_

        The Kubernetes version for the node pool, defaults to the latest version. This value must be specified for cluster upgrade to work.

    - (number) **`max_pods_per_node = null`** _[since v0.0.1]_

        The max number of pods that can be deployed on each node. Defaults to `30`

    - (number) **`max_instances = null`** _[since v0.0.1]_

        The maximum number of nodes this pool can scale up to. `cluster auto scaling` will be enabled if both this and `min_instances` are specified.

    - (number) **`min_instances = null`** _[since v0.0.1]_

        The minimum number of nodes this pool can scale down to. `cluster auto scaling` will be enabled if both this and `man_instances` are specified.

    - (list(string)) **`zones = null`** _[since v0.0.1]_

        A list of availability zones the nodes should be deployed onto

### Optional

- (object) **`add_ons = null`** _[since v0.0.1]_

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

    - (object) **`azure_key_vault_secrets_provider = null`** _[since v0.0.1]_

        Configures the [Azure Key Vault Provider][azure-key-vault-provider] add-on

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables this add-on

        - (string) **`key_vault_name`** _[since v0.0.1]_

            Name of the Azure Key Vault to allow this cluster to retrieve secrets from

        - (number) **`secret_rotation_interval_minutes = 2`** _[since v0.0.1]_

            The interval in minutes that the secrets in the cluster will be refreshed

    - (object) **`azure_policy = null`** _[since v0.0.1]_

        Configures the [Azure Policy][azure-policy] add-on

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables this add-on

    - (object) **`monitoring = null`** _[since v0.0.1]_

        Configures the [Container Insights][container-insights] add-on

        - (bool) **`enabled`** _[since v0.0.1]_

            Enables this add-on

        - (number) **`retention_days = 60`** _[since v0.0.1]_

            How long in days the logs will be retained

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the Kubernetes cluster

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (list(string)) **`apiserver_authorized_ip_ranges = ["0.0.0.0/0"]`** _[since v0.0.1]_

    List of IP addresses that are allowed to communicate with the API server. This option is only available if `enable_private_cluster = false`

- (list(string)) **`azure_container_registry_attachments = []`** _[since v0.0.1]_

    List of ACR resource IDs to grant pull access to the cluster's kubelet identity. Please refer to [this document][acr-integration] for more information

- (bool) **`enable_private_cluster = false`** _[since v0.0.1]_

    Enables [private AKS cluster][private-aks-cluster], where the control plane can only be accessed internally

- (string) **`kubernetes_version = null`** _[since v0.0.1]_

    The Kubernetes version for the control plane. The `latest` version is used if unspecified. This value must be specified to enable cluster upgrade.

- (object) **`networking_config = null`** _[since v0.0.1]_

    Networking options for the Kubernetes control plane

    ```terraform
    networking_config = {
      plugin = "kubenet"
    }
    ```

    - (string) **`plugin`** _[since v0.0.1]_

        The Kubernetes network plugin to use. Valid values are `kubenet` and `azure`

    - (string) **`docker_bridge_address = 172.17.0.1/16`** _[since v0.0.1]_

        IP address (in CIDR notation) used as the Docker bridge IP address on nodes

    - (string) **`kubernetes_dns_service_ip_address = 10.0.0.10`** _[since v0.0.1]_

        IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)

    - (string) **`kubernetes_pod_address_range = 10.244.0.0/16`** _[since v0.0.1]_

        The CIDR to use for pod IP addresses. This field can only be set when `plugin = kubenet`

    - (string) **`kubernetes_service_address_range = 10.0.0.0/16`** _[since v0.0.1]_

        The Network Range used by the Kubernetes service

- (list(string)) **`user_assigned_managed_identity_ids = []`** _[since v0.0.1]_

    List of managed identity IDs used by the cluster to manage azure resources

[azure-kubernetes-service]:https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes
[azure-vm-size]:https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
[azure-vm-naming-convention]:https://docs.microsoft.com/en-us/azure/virtual-machines/vm-naming-conventions
[private-aks-cluster]:https://docs.microsoft.com/en-us/azure/aks/private-clusters
[aks-add-ons]:https://docs.microsoft.com/en-us/azure/aks/integrations#add-ons
[container-insights]:https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
[azure-policy]:https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
[azure-key-vault-provider]:https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
[acr-integration]:https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli
