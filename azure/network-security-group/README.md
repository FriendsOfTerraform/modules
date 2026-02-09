# Network Security Group Module

This module creates an Azure [Network Security Group][network-security-group] and allows you to manage multiple inbound and outbound rules

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

This example creates a network security group, and then multiple inbound rules.

```terraform
module "demo_nsg" {
  source = "github.com/FriendsOfTerraform/azure-network-security-group.git?ref=v1.0.0"

  azure = {
    resource_group_name = "sandbox"
    location = "westus" # if unspecified, resource group's location will be used
  }

  name                = "demo-nsg"

  additional_tags_all = {
    created-by = "Peter Sin" # Tag all resources with the creator information
  }

  inbound_security_rules = {
    rdp = {
      priority            = 100
      description         = "Allows RDP from a particular CIDR"
      source_ip_addresses = ["10.0.0.0/24"]
      port_ranges         = ["3389"]
    }
    web-frontend = {
      priority    = 200
      description = "Allows HTTPS from Anywhere"
      port_ranges = ["443"]
    }
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
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the network security group. This will also be used as a prefix to all associating resources' names.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>


### Optional



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the network security group

    

    

    

    

    
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
    <td><code>map(object(<a href="#inboundsecurityrules">InboundSecurityRules</a>))</code></td>
    <td width="100%">inbound_security_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple inbound security rules, in `{rule_name = {configuration}}` format.

```terraform
inbound_security_rules = {
rdp = {
priority            = 100
description         = "Allows RDP from a particular CIDR"
source_ip_addresses = ["10.0.0.0/24"]
port_ranges         = ["3389"]
}
}
```

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#outboundsecurityrules">OutboundSecurityRules</a>))</code></td>
    <td width="100%">outbound_security_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple outbound security rules, in `{rule_name = {configuration}}` format.

```terraform
outbound_security_rules = {
dns = {
priority    = 100
description = "Allow all outbound DNS call"
port_ranges = ["53"]
protocol    = "Udp"
}
}
```

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the network security group

    

    

    

    

    
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



#### InboundSecurityRules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

The priority of the rule. Lower number has higher priority

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">action</td>
    <td><code>"Allow"</code></td>
</tr>
<tr><td colspan="3">

Defines if the matching rule should be allowed or denied.

    
**Allowed Values:**
- `Allow`
- `Deny`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Description of the security rule

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">destination_application_security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">destination_ip_addresses</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">destination_service_tag</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">port_ranges</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td><code>"Tcp"</code></td>
</tr>
<tr><td colspan="3">

The protocol of the connection that matches this rule.

    
**Allowed Values:**
- `Tcp`
- `Udp`
- `Icmp`
- `Esp`
- `Ah`
- `*`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">source_application_security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">source_ip_addresses</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_service_tag</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### OutboundSecurityRules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

The priority of the rule. Lower number has higher priority

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">action</td>
    <td><code>"Allow"</code></td>
</tr>
<tr><td colspan="3">

Defines if the matching rule should be allowed or denied.

    
**Allowed Values:**
- `Allow`
- `Deny`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Description of the security rule

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">destination_application_security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">destination_ip_addresses</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">destination_service_tag</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">port_ranges</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td><code>"Tcp"</code></td>
</tr>
<tr><td colspan="3">

The protocol of the connection that matches this rule.

    
**Allowed Values:**
- `Tcp`
- `Udp`
- `Icmp`
- `Esp`
- `Ah`
- `*`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">source_application_security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">source_ip_addresses</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_service_tag</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>




[service-tag]: https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags


<!-- TFDOCS_EXTRAS_END -->

[network-security-group]:https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
