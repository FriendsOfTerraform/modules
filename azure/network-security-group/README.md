# Network Security Group Module

This module creates an Azure [Network Security Group][network-security-group] and allows you to manage multiple inbound and outbound rules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

This example creates a network security group, and then multiple inbound rules.

```terraform
module "demo_nsg" {
  source = "github.com/FriendsOfTerraform/azure-network-security-group.git?ref=v0.0.1"

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

- (string) **`name`** _[since v0.0.1]_

    The name of the network security group. This will also be used as a prefix to all associating resources' names.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the network security group

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (map(object)) **`inbound_security_rules = {}`** _[since v0.0.1]_

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

    - (number) **`priority`** _[since v0.0.1]_

        The priority of the rule. Lower number has higher priority

    - (string) **`action = "Allow"`** _[since v0.0.1]_

        Defines if the matching rule should be allowed or denied. Valid values are `Allow` and `Deny`

    - (string) **`description = null`** _[since v0.0.1]_

        Description of the security rule

    - (list(string)) **`destination_application_security_group_ids = null`** _[since v0.0.1]_

        Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (list(string)) **`destination_ip_addresses = null`** _[since v0.0.1]_

        Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (string) **`destination_service_tag = null`** _[since v0.0.1]_

        Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (list(string)) **`port_ranges = "*"`** _[since v0.0.1]_

        Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`

    - (string) **`protocol = "Tcp"`** _[since v0.0.1]_

        The protocol of the connection that matches this rule. Valid options are `"Tcp", "Udp", "Icmp", "Esp", "Ah", and "*"`

    - (list(string)) **`source_application_security_group_ids = null`** _[since v0.0.1]_

        Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    - (list(string)) **`source_ip_addresses = null`** _[since v0.0.1]_

        Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    - (string) **`source_service_tag = null`** _[since v0.0.1]_

        Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.

- (map(object)) **`outbound_security_rules = {}`** _[since v0.0.1]_

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

    - (number) **`priority`** _[since v0.0.1]_

        The priority of the rule. Lower number has higher priority

    - (string) **`action = "Allow"`** _[since v0.0.1]_

        Defines if the matching rule should be allowed or denied. Valid values are `Allow` and `Deny`

    - (string) **`description = null`** _[since v0.0.1]_

        Description of the security rule

    - (list(string)) **`destination_application_security_group_ids = null`** _[since v0.0.1]_

        Defines a list of destination application security group IDs that match this rule. This option is mutually exclusive to `destination_ip_addresses` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (list(string)) **`destination_ip_addresses = null`** _[since v0.0.1]_

        Defines a list of destination ip addresses or CIDR that match this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_service_tag`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (string) **`destination_service_tag = null`** _[since v0.0.1]_

        Defines a destination [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `destination_application_security_group_ids` and `destination_ip_addresses`. If none of the destinations are specified, all destinations (`Any`) will be used.

    - (list(string)) **`port_ranges = "*"`** _[since v0.0.1]_

        Defines a list of port ranges that match this rule. Input can either be a range eg. `"0-1024"` or a port number eg. `"8080"`

    - (string) **`protocol = "Tcp"`** _[since v0.0.1]_

        The protocol of the connection that matches this rule. Valid options are `"Tcp", "Udp", "Icmp", "Esp", "Ah", and "*"`

    - (list(string)) **`source_application_security_group_ids = null`** _[since v0.0.1]_

        Defines a list of source application security group IDs that match this rule. This option is mutually exclusive to `source_ip_addresses` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    - (list(string)) **`source_ip_addresses = null`** _[since v0.0.1]_

        Defines a list of source ip addresses or CIDR that match this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_service_tag`. If none of the sources are specified, all sources (`Any`) will be used.

    - (string) **`source_service_tag = null`** _[since v0.0.1]_

        Defines a source [Service Tag][service-tag] that matches this rule. This option is mutually exclusive to `source_application_security_group_ids` and `source_ip_addresses`. If none of the sources are specified, all sources (`Any`) will be used.

## Outputs

- (string) **`id`** _[since v0.0.1]_

    The ID of the network security group

[network-security-group]:https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
[service-tag]:https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview#available-service-tags
