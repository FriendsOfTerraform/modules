# Security Group Module

This module will build and configure a [Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) and multiple rules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

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

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the security group. All associated resources will also have their name prefixed with this value

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the security group

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (string) **`description = null`** _[since v1.0.0]_

    Description of the security group

- (map(object)) **`egress_rules = {}`** _[since v1.0.0]_

    Configures multiple [egress rules][security-group-rules]. [See example](#basic-usage)

    - (list(string)) **`destinations`** _[since v1.0.0]_

        A list of destinations this rule applies to. Destinations can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the egress rule

    - (string) **`description = null`** _[since v1.0.0]_

        Description for the egress rule

- (map(object)) **`ingress_rules = {}`** _[since v1.0.0]_

    Configures multiple [ingress rules][security-group-rules]. [See example](#basic-usage)

    - (list(string)) **`sources`** _[since v1.0.0]_

        A list of sources this rule applies to. Sources can be a combination of IPv4 CIDRs, IPv6 CIDRs, security group IDs, or prefix list IDs

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the ingress rule

    - (string) **`description = null`** _[since v1.0.0]_

        Description for the ingress rule

## Outputs

- (string) **`security_group_arn`** _[since v1.0.0]_

    ARN of the security group

- (string) **`security_group_id`** _[since v1.0.0]_

    ID of the security group

[security-group-rules]:https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
