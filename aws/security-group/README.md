# Security Group Module

This module will build and configure a [Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) and multiple rules

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

```terraform
module "security_group_basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-security-group.git?ref=v1.0.0"

  name   = "security-group-demo"
  vpc_id = "vpc-01b9cfd1a2b3c4d5e"

  ingress_rules = {
    # The keys of the map will be the <port_range>/<protocol>
    # Protocol can be "tcp", "udp", "icmp", "icmpv6", "all_tcp", "all_udp"
    # You do not need to specify port range with protocol other than "tcp" and "udp"

    # single TCP port
    "443/tcp" = {
      sources     = [ "0.0.0.0/0", "::/0" ]
      description = "allow ingress HTTPS from everywhere"
    }

    # range of TCP ports
    "9100-9103/tcp" = {
      sources     = [ "sg-00ce1701a2b3c4d5e" ] # prometheus servers
      description = "allow TCP port 9100 - 9103 for monitoring application"
    }

    # ICMP
    "icmp" = {
      sources     = [ "sg-00ce1701111222aaa" ] # IT operator security group
      description = "allow ICMP to all IT operators machines for troubleshooting"
    }

    # All TCP ports
    "all_tcp" = {
      sources = [
        "10.0.0.102/32", # Peter's laptop
        "10.0.0.103/32", # Stewie's laptop
        "10.0.0.104/32"  # Chris' laptop
      ]
      description = "allow full TCP access to selected admin laptops"
    }
  }

  egress_rules = {
    "53/udp" = {
      destinations = [ "pl-1a2b3c4d" ] # DNS servers
      description  = "Allow outbound access to DNS servers"
    }
    "8888/tcp" = {
      destinations = [ "10.0.10.103/32" ] # Software update server
      description  = "Allow outbound access to update servers"
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the security group. All associated resources will also have their name prefixed with this value

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vpc_id</td>
    <td></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


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

Additional tags for the security group

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Description of the security group

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#egressrules">EgressRules</a>))</code></td>
    <td width="100%">egress_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple [egress rules][security-group-rules].

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#ingressrules">IngressRules</a>))</code></td>
    <td width="100%">ingress_rules</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple [ingress rules][security-group-rules].

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">security_group_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the security group

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">security_group_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ID of the security group

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### EgressRules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">destinations</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of destinations this rule applies to. Destinations can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the egress rule

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Description for the egress rule

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### IngressRules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">sources</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of sources this rule applies to. Sources can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the ingress rule

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Description for the ingress rule

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[security-group-rules]: https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html


<!-- TFDOCS_EXTRAS_END -->
