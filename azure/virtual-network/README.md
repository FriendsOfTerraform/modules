# Virtual Network Module

This module will create and configure an [Azure virtual network][azure-virtual-network] and its associated resources such as subnets and NAT gateways.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Requirements](#requirements)
- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
- [Outputs](#outputs)
- [Known Issues](#known-issues)

## Requirements

- Terraform v1.3.0+

## Example Usage

### Basic Usage

This example creates a virtual network with two subnets and having all outbound traffic goes out via the NAT gateway.

```terraform
module "demo_vnet" {
  source = "github.com/FriendsOfTerraform/azure-virtual-network.git?ref=v1.0.0"

  azure = {
    resource_group_name = "sandbox"
    location = "westus" # if unspecified, resource group's location will be used
  }

  name                = "demo-vnet"
  cidr_blocks         = ["10.0.0.0/24"]

  additional_tags_all = {
    created-by = "Peter Sin" # Tag all resources with the creator information
  }

  subnets = {
    subnet-1 = { cidr_block = "10.0.0.0/26" }
    subnet-2 = { cidr_block = "10.0.0.64/26" }
  }

  nat_gateway = {
    enabled = true
  }
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

        The name of an Azure resource group where the virtual network will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the virtual network will be deployed. If unspecified, the resource group's location will be used.

- (list(string)) **`cidr_blocks`** _[since v0.0.1]_

    List of CIDR blocks for the virtual network

- (string) **`name`** _[since v0.0.1]_

    The name of the virtual network. This will also be used as a prefix to all associating resources' names.

### Optional

- (list(string)) **`additional_dns_server_addresses = []`** _[since v0.0.1]_

    Additional DNS server addresses on top of Azure's default DNS server

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the virtual network

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (string) **`ddos_protection_plan_id = null`** _[since v0.0.1]_

    The DDOS protection plan to be assigned to this vnet

- (object) **`nat_gateway = {enabled = false}`** _[since v0.0.1]_

    Enables and configures [NAT gateways][azure-nat-gateway] for the virtual network

    ```terraform
    nat_gateway = {
      enabled = true
      public_ip_prefix_length = "28" # 16 IP addresses
    }
    ```

    - (bool) **`enabled`** _[since v0.0.1]_

        Enables the NAT gateway if `true`

    - (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

        Additional tags for the NAT gateways

    - (string) **`public_ip_prefix_length = null`** _[since v0.0.1]_

        The CIDR length of the public IP prefix to be used by the NAT gateway. If this value is unspecified, a public IP address will be used instead.

- (list(string)) **`service_endpoints = []`** _[since v0.0.1]_

    A list of service endpoints to be enabled on all subnets. Please refer to [this document][service-endpoints] for a list of possible values

- (map(object)) **`subnets = {}`** _[since v0.0.1]_

    Creates and configures subnets. Expected input in the `{subnetName = {configuration}}` format.

    ```terraform
    subnets = {
      subnet-1 = { cidr_block = "10.0.0.0/26" }  # Creates a subnet named subnet-1 with the cidr 10.0.0.0/26
      subnet-2 = { cidr_block = "10.0.0.64/26" } # Creates a subnet named subnet-2 with the cidr 10.0.0.64/26
    }
    ```

    - (string) **`cidr_block`** _[since v0.0.1]_

        The CIDR for the subnet

    - (string) **`network_security_group_id = null`** _[since v0.0.1]_

        The ID of an Azure network security group to be attached to this subnet

    - (string) **`route_table_name = null`** _[since v0.0.1]_

        The name of a route table to be attached to this subnet

    - (list(string)) **`service_endpoints = []`** _[since v0.0.1]_

        A list of service endpoints to be enabled in this subnet. Please refer to [this document][service-endpoints] for a list of possible values

## Outputs

- (string) **`virtual_network_id`** _[since v0.0.1]_

    The ID of the virtual network

[azure-virtual-network]:https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
[azure-nat-gateway]:https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview
[service-endpoints]:https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
