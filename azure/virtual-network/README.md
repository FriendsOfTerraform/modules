# Virtual Network Module

This module will create and configure an [Azure virtual network][azure-virtual-network] and its associated resources such as subnets and NAT gateways.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Requirements](#requirements)
- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure">Azure</a>)</code></td>
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
    <td width="100%">cidr_blocks</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of CIDR blocks for the virtual network

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the virtual network. This will also be used as a prefix to all associating resources' names.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>


### Optional



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">additional_dns_server_addresses</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

Additional DNS server addresses on top of Azure's default DNS server

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the virtual network

    

    

    

    

    
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
    <td><code>string</code></td>
    <td width="100%">ddos_protection_plan_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The DDOS protection plan to be assigned to this vnet

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>object(<a href="#natgateway">NatGateway</a>)</code></td>
    <td width="100%">nat_gateway</td>
    <td><code>{
  "enabled": false
}</code></td>
</tr>
<tr><td colspan="3">

Enables and configures [NAT gateways][azure-nat-gateway] for the virtual network

```terraform
nat_gateway = {
enabled = true
public_ip_prefix_length = "28" # 16 IP addresses
}
```

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">service_endpoints</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

A list of service endpoints to be enabled on all subnets. Please refer to [this document][service-endpoints] for a list of possible values

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#subnets">Subnets</a>))</code></td>
    <td width="100%">subnets</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Creates and configures subnets. Expected input in the `{subnetName = {configuration}}` format.

```terraform
subnets = {
subnet-1 = { cidr_block = "10.0.0.0/26" }  # Creates a subnet named subnet-1 with the cidr 10.0.0.0/26
subnet-2 = { cidr_block = "10.0.0.64/26" } # Creates a subnet named subnet-2 with the cidr 10.0.0.64/26
}
```

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>unknown</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">virtual_network_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the virtual network

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>

## Objects



#### Azure



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the virtual network will be deployed

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the virtual network will be deployed. If unspecified, the resource group's location will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### NatGateway



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables the NAT gateway if `true`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">public_ip_prefix_length</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The CIDR length of the public IP prefix to be used by the NAT gateway. If this value is unspecified, a public IP address will be used instead.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the NAT gateways

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### Subnets



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cidr_block</td>
    <td></td>
</tr>
<tr><td colspan="3">

The CIDR for the subnet

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">network_security_group_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of an Azure network security group to be attached to this subnet

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">route_table_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of a route table to be attached to this subnet

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">service_endpoints</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of service endpoints to be enabled in this subnet. Please refer to [this document][service-endpoints] for a list of possible values

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>




[azure-nat-gateway]: https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview

[service-endpoints]: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview


<!-- TFDOCS_EXTRAS_END -->

[azure-virtual-network]:https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
