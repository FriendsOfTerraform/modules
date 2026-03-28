# Kubernetes Service Module

This module will create and configure an [Azure Kubernetes Cluster][azure-kubernetes-service] with additional node pools

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

This example creates an AKS cluster with a `default node pool` and a `secondary node pool`. The `secondary node pool` will be configured with cluster auto scaling. Because Azure CNI requires an existing vnet, we will create one here as well.

```terraform
module "aks_vnet" {
  source = "github.com/FriendsOfTerraform/azure-virtual-network.git?ref=v1.0.0"

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
  kubernetes_version = "1.26"
}

module "aks_cluster" {
  source = "github.com/FriendsOfTerraform/azure-kubernetes-service.git?ref=v1.0.0"

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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure">azure</a>)</code></td>
    <td width="100%">azure</td>
    <td></td>
</tr>
<tr><td colspan="3">

The resource group name and the location where the resources will be deployed to

```terraform
azure = {
resource_group_name = "sandbox"
location = "westus"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">cluster_admin_active_directory_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of Azure active directory group IDs that will be added as the `cluster admins` on the cluster

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the Kubernetes cluster. This will also be used as a prefix to all associating resources' names.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#node_pools">node_pools</a>))</code></td>
    <td width="100%">node_pools</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the cluster's node pools. In `{node_pool_name = {configurations}}` format

```terraform
default = {
vm_size            = "Standard_DS2_v2"
vnet_subnet_id     = module.aks_vnet.subnet_ids["default-node-pool"] # referencing the default-node-pool subnet in the aks_vnet module
desired_instances  = 2
kubernetes_version = local.kubernetes_version
}
```

**Since:** 0.0.1

</td></tr>
</tbody></table>

### Optional

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#add_ons">add_ons</a>)</code></td>
    <td width="100%">add_ons</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the Kubernetes cluster

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">apiserver_authorized_ip_ranges</td>
    <td><code>[
  "0.0.0.0/0"
]</code></td>
</tr>
<tr><td colspan="3">

List of IP addresses that are allowed to communicate with the API server. This option is only available if `enable_private_cluster = false`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">azure_container_registry_attachments</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of ACR resource IDs to grant pull access to the cluster's kubelet identity. Please refer to [this document][acr-integration] for more information

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_private_cluster</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [private AKS cluster][private-aks-cluster], where the control plane can only be accessed internally

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kubernetes_version</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The Kubernetes version for the control plane. The `latest` version is used if unspecified. This value must be specified to enable cluster upgrade.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#networking_config">networking_config</a>)</code></td>
    <td width="100%">networking_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Networking options for the Kubernetes control plane

```terraform
networking_config = {
plugin = "kubenet"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">user_assigned_managed_identity_ids</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of managed identity IDs used by the cluster to manage azure resources

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Objects

#### add_ons

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure_key_vault_secrets_provider">azure_key_vault_secrets_provider</a>)</code></td>
    <td width="100%">azure_key_vault_secrets_provider</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the [Azure Key Vault Provider][azure-key-vault-provider] add-on

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#azure_policy">azure_policy</a>)</code></td>
    <td width="100%">azure_policy</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the [Azure Policy][azure-policy] add-on

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#monitoring">monitoring</a>)</code></td>
    <td width="100%">monitoring</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the [Container Insights][container-insights] add-on

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### azure

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the cluster will be deployed

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the cluster will be deployed. If unspecified, the resource group's location will be used.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### azure_key_vault_secrets_provider

Configures the [Azure Key Vault Provider][azure-key-vault-provider] add-on

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables this add-on

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">key_vault_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of the Azure Key Vault to allow this cluster to retrieve secrets from

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">secret_rotation_interval_minutes</td>
    <td><code>2</code></td>
</tr>
<tr><td colspan="3">

The interval in minutes that the secrets in the cluster will be refreshed

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### azure_policy

Configures the [Azure Policy][azure-policy] add-on

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables this add-on

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### monitoring

Configures the [Container Insights][container-insights] add-on

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables this add-on

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retention_days</td>
    <td><code>60</code></td>
</tr>
<tr><td colspan="3">

How long in days the logs will be retained

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### networking_config

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">plugin</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Kubernetes network plugin to use.

**Allowed Values:**

- `kubenet`
- `azure`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kubernetes_service_address_range</td>
    <td><code>"10.0.0.0/16"</code></td>
</tr>
<tr><td colspan="3">

The Network Range used by the Kubernetes service

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kubernetes_dns_service_ip_address</td>
    <td><code>"10.0.0.10"</code></td>
</tr>
<tr><td colspan="3">

IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">docker_bridge_address</td>
    <td><code>"172.17.0.1/16"</code></td>
</tr>
<tr><td colspan="3">

IP address (in CIDR notation) used as the Docker bridge IP address on nodes

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kubernetes_pod_address_range</td>
    <td><code>"10.244.0.0/16"</code></td>
</tr>
<tr><td colspan="3">

The CIDR to use for pod IP addresses. This field can only be set when `plugin = kubenet`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### node_pools

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">desired_instances</td>
    <td></td>
</tr>
<tr><td colspan="3">

The initial number of nodes for this node pool

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vm_size</td>
    <td></td>
</tr>
<tr><td colspan="3">

[Azure VM size][azure-vm-size]. Also see [Azure VM Naming Convention][azure-vm-naming-convention]

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vnet_subnet_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the subnet where new nodes from this pool will be deployed into

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for this node pool

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">disk_size</td>
    <td><code>512</code></td>
</tr>
<tr><td colspan="3">

The size of OS disk in GB, defaults to `512 GB`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kubernetes_version</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The Kubernetes version for the node pool, defaults to the latest version. This value must be specified for cluster upgrade to work.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_pods_per_node</td>
    <td><code>30</code></td>
</tr>
<tr><td colspan="3">

The max number of pods that can be deployed on each node.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_instances</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The maximum number of nodes this pool can scale up to. `cluster auto scaling` will be enabled if both this and `min_instances` are specified.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">min_instances</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The minimum number of nodes this pool can scale down to. `cluster auto scaling` will be enabled if both this and `man_instances` are specified.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">zones</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of availability zones the nodes should be deployed onto

**Since:** 0.0.1

</td></tr>
</tbody></table>

[acr-integration]: https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli
[aks-add-ons]: https://docs.microsoft.com/en-us/azure/aks/integrations#add-ons
[azure-key-vault-provider]: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
[azure-policy]: https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
[azure-vm-naming-convention]: https://docs.microsoft.com/en-us/azure/virtual-machines/vm-naming-conventions
[azure-vm-size]: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
[container-insights]: https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
[private-aks-cluster]: https://docs.microsoft.com/en-us/azure/aks/private-clusters

<!-- TFDOCS_EXTRAS_END -->

[azure-kubernetes-service]: https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes
