# Virtual Private Cloud Module

This module creates and configures a [VPC](https://aws.amazon.com/vpc/) and multiple subnets, route tables, and gateways

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Flow Logs](#flow-logs)
    - [Peering Connection Requests](#peering-connection-requests)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
- [Known Limitations](#known-limitations)
    - [default route table](#default_route_table)
    - [vpc_endpoint_id conflicts with destination_prefix_list_id](#vpc_endpoint_id-conflicts-with-destination_prefix_list_id)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-vpc.git?ref=v1.1.0"

  name = "demo-vpc"

  # When create_nat_gateways = true, one NAT gateway will be created on each public subnets' availability zone
  # You can reference the gateway in the route table using "default-nat-gateway/<availability_zone>"
  # See below for an example
  create_nat_gateways = true

  cidr_block = {
    ipv4 = {
      cidr = "10.0.4.0/22"
    }
  }

  subnets = {
    # The key of the map will be the subnet's name
    # A subnet is considered public if enable_auto_assign_public_ipv4_address = true
    # An internet gateway will be created if at least one subnet is public
    public-us-west-1a = {
      ipv4_cidr_block                        = "10.0.4.0/24"
      availability_zone                      = "us-west-1a"
      enable_auto_assign_public_ipv4_address = true
    }
    public-us-west-1b = {
      ipv4_cidr_block                        = "10.0.5.0/24"
      availability_zone                      = "us-west-1b"
      enable_auto_assign_public_ipv4_address = true
    }
    private-us-west-1a = {
      ipv4_cidr_block   = "10.0.6.0/24"
      availability_zone = "us-west-1a"
    }
    private-us-west-1b = {
      ipv4_cidr_block   = "10.0.7.0/24"
      availability_zone = "us-west-1b"
    }
  }

  route_tables = {
    # The key of the map will be the route table's name
    "public-route-table" = {
      routes = {
        # The key of the route will be the destination
        # The value of the route will be the target
        # default-internet-gateway refers to the internet gateway this module created
        "0.0.0.0/0"   = "default-internet-gateway"
        "10.0.10.0/16 = "tgw-012345a9e9dabcdef"
      }
      subnet_associations = ["public-us-west-1a", "public-us-west-1b"]
    },
    "private-us-west-1a-route-table" = {
      routes = {
        # default-nat-gateway/us-west-1a refers to the NAT gateway in the us-west-1a availability zone
        "0.0.0.0/0" = "default-nat-gateway/us-west-1a"
      }
      subnet_associations = ["private-us-west-1a"]
    },
    "private-us-west-1b-route-table" = {
      routes = {
        "0.0.0.0/0" = "default-nat-gateway/us-west-1b"
      }
      subnet_associations = ["private-us-west-1b"]
    }
  }
}
```

### Flow Logs

You can create flow logs at the VPC or the subnet level

```terraform
module "flow_logs" {
  source = "github.com/FriendsOfTerraform/aws-vpc.git?ref=v1.1.0"

  name = "demo-vpc"

  cidr_block = {
    ipv4 = {
      cidr = "10.0.4.0/22"
    }
  }

  subnets = {
    public-us-west-1a = {
      ipv4_cidr_block                        = "10.0.4.0/24"
      availability_zone                      = "us-west-1a"
      enable_auto_assign_public_ipv4_address = true
    }
    private-us-west-1a = {
      ipv4_cidr_block   = "10.0.6.0/24"
      availability_zone = "us-west-1a"

      # Manages multiple subnet level flow logs
      flow_logs = {
        # The key of the map will be the flow log's name
        subnet-flow-log = {
          destination = {
            cloudwatch_logs = {
              log_group_arn = "arn:aws:logs:us-west-1:111122223333:log-group:demo-flow-logs-log-group"
            }
          }
        }
      }
    }
  }

  # Manages multiple VPC level flow logs
  flow_logs = {
    # The key of the map will be the flow log's name
    vpc-flow-log = {
      destination = {
        s3 = {
          bucket_arn = "arn:aws:s3:::demo-flow-logs-bucket"
        }
      }
    }
  }
}
```

### Peering Connection Requests

```terraform
module "peering_connection_requests" {
  source = "github.com/FriendsOfTerraform/aws-vpc.git?ref=v1.1.0"

  name = "demo-vpc"

  cidr_block = {
    ipv4 = {
      cidr = "10.0.4.0/22"
    }
  }

  peering_connection_requests = {
    # The key of the map will be the peering connection name
    # For peering connection requests at the same account and region, the connection will be automatically accepted
    "peering-same-acccount-and-region" = {
      peer_vpc_id = "vpc-0123450af84abcdef"
    }

    # For peering connection requests at different account and/or region, a separate aws_vpc_peering_connection_accepter resource
    # must be created at the target account/region to manage the accepter's side of the connection
    "peering-same-account-different-region" = {
      peer_vpc_id = "vpc-987654abcdabcdef"
      peer_region = "us-east-1"
    }
  }

  route_tables = {
    "private-route-table" = {
      routes = {
        # Peering connections created with this module can be referenced by name as a route target
        "10.0.0.0/16"     = "peering-same-acccount-and-region"
        "172.25.100.0/24" = "peering-same-account-different-region"
      }
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#cidrblock">CidrBlock</a>)</code></td>
    <td width="100%">cidr_block</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the VPC CIDR block

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the VPC. All associated resources will also have their name prefixed with this value

    

    

    

    

    
**Since:** 1.0.0
        


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

Additional tags for the VPC

    

    

    

    

    
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
    <td><code>bool</code></td>
    <td width="100%">create_nat_gateways</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled, one NAT gateway will be created on the first public subnets in each availability zone. You can then refer to them on the route table with `default-nat-gateway/<availability_zone_name>`.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#dhcpoptions">DhcpOptions</a>)</code></td>
    <td width="100%">dhcp_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

DHCP option sets give you control over various aspects of routing in your virtual network, such as the DNS servers, domain names, or Network Time Protocol (NTP) servers used by the devices in your VPC. The Amazon default option set will be used if not specified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#dnssettings">DnsSettings</a>)</code></td>
    <td width="100%">dns_settings</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures DNS settings for the VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_network_address_usage_metrics</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

[Network Address Usage (NAU)][vpc-network-address-usage] is a metric applied to resources in your virtual network to help you plan for and monitor the size of your VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#flowlogs">FlowLogs</a>))</code></td>
    <td width="100%">flow_logs</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple VPC level flow logs.

    

    

    
**Examples:**
- [Flow Logs](#flow-logs)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#peeringconnectionrequests">PeeringConnectionRequests</a>))</code></td>
    <td width="100%">peering_connection_requests</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple VPC peering connection requests.

    

    

    
**Examples:**
- [Peering Connection Requests](#peering-connection-requests)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#routetables">RouteTables</a>))</code></td>
    <td width="100%">route_tables</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple route tables.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#subnets">Subnets</a>))</code></td>
    <td width="100%">subnets</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple subnets.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">tenancy</td>
    <td><code>"default"</code></td>
</tr>
<tr><td colspan="3">

Specify the VPC's tenancy.

    
**Allowed Values:**
- `default`
- `dedicated`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#dhcpoptions">DhcpOptions</a>))</code></td>
    <td width="100%">dhcp_options</td>
    <td></td>
</tr>
<tr><td colspan="3">

DHCP option

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#internetgateway">InternetGateway</a>))</code></td>
    <td width="100%">internet_gateway</td>
    <td></td>
</tr>
<tr><td colspan="3">

The default internet gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#natgateways">NatGateways</a>))</code></td>
    <td width="100%">nat_gateways</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of default NAT gateways. The key of the map is the NAT gateway's name

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#peeringconnectionrequests">PeeringConnectionRequests</a>))</code></td>
    <td width="100%">peering_connection_requests</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of peering connection requests. The key of the map is the peering connection request's name

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#routetables">RouteTables</a>))</code></td>
    <td width="100%">route_tables</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of route tables. The key of the map is the route table's name

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#subnets">Subnets</a>))</code></td>
    <td width="100%">subnets</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of subnets. The key of the map is the subnet's name

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vpc_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">vpc_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### CidrBlock



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#ipv4">Ipv4</a>)</code></td>
    <td width="100%">ipv4</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the IPv4 CIDR block

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### CloudwatchLogs

Configures CloudWatch Logs as destination

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">log_group_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the CloudWatch log group to send logs to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">service_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Arn of an IAM role that [gives permission to flow logs to send logs to CloudWatch][vpc-flow-logs-cloudwatch-service-role]. A default service role will be created if not specified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Destination

Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#cloudwatchlogs">CloudwatchLogs</a>)</code></td>
    <td width="100%">cloudwatch_logs</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures CloudWatch Logs as destination

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#s3">S3</a>)</code></td>
    <td width="100%">s3</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures S3 as destination

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DhcpOptions



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the DHCP option

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the DHCP option

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DnsSettings



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_dns_resolution</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether DNS resolution through the Amazon DNS server is supported for the VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_dns_hostnames</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether instances launched in the VPC receive public DNS hostnames that correspond to their public IP addresses

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### FlowLogs

Configures multiple subnet level flow logs.

    

    

    
**Examples:**
- [Flow Logs](#flow-logs)

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#destination">Destination</a>)</code></td>
    <td width="100%">destination</td>
    <td></td>
</tr>
<tr><td colspan="3">

Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the flow log

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">custom_log_record_format</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">filter</td>
    <td><code>"ALL"</code></td>
</tr>
<tr><td colspan="3">

The type of traffic to capture.

    
**Allowed Values:**
- `ALL`
- `ACCEPT`
- `REJECT`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_aggregation_interval</td>
    <td><code>600</code></td>
</tr>
<tr><td colspan="3">

The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record.

    
**Allowed Values:**
- `60`
- `600`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### InternetGateway



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the internet gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the internet gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">owner_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the AWS account that owns the internet gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Ipam

Specify an [Amazon VPC IP Address Manager (IPAM)][vpc-ipam] pool to obtain an IPv4 CIDR automatically. If you select an IPAM pool, the size of the CIDR is limited by the allocation rules on the IPAM pool (allowed minimum, allowed maximum, and default). Mutually exclusive to `cidr`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">pool_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">netmask</td>
    <td></td>
</tr>
<tr><td colspan="3">

The netmask length of the IPv4 CIDR you want to allocate to this VPC

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Ipv4

Configures the IPv4 CIDR block

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cidr</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manually input an IPv4 CIDR. The CIDR block size must have a size between /16 and /28. Mutually exclusive to `ipam`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#ipam">Ipam</a>)</code></td>
    <td width="100%">ipam</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an [Amazon VPC IP Address Manager (IPAM)][vpc-ipam] pool to obtain an IPv4 CIDR automatically. If you select an IPAM pool, the size of the CIDR is limited by the allocation rules on the IPAM pool (allowed minimum, allowed maximum, and default). Mutually exclusive to `cidr`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NatGateways



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">availability_zone</td>
    <td></td>
</tr>
<tr><td colspan="3">

The availability of the NAT gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">association_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The association ID of the Elastic IP address that's associated with the NAT Gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the NAT gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">network_interface_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the network interface associated with the NAT Gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">public_ip</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Elastic IP address associated with the NAT Gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PeeringConnectionRequests



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The peering connection ID

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">accept_status</td>
    <td></td>
</tr>
<tr><td colspan="3">

The status of the VPC Peering Connection request

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ResourceBasedNameSettings

Specify the hostname type for EC2 instances in this subnet and optional RBN DNS query settings

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_resource_name_dns_a_record_on_launch</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Choose if DNS A record queries for the resource-based name should return the IPv4 address or not

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">hostname_type</td>
    <td><code>"ip-name"</code></td>
</tr>
<tr><td colspan="3">

Determines if the guest OS hostname of EC2 instances in this subnet should be based on the resource name (RBN) or the IP name (IPBN).

- If you choose `"resource-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use the EC2 instance ID: `ec2-instance-id.region.compute.internal`.
- If you choose `"ip-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use an IP-based name: `private-ipv4-address.region.compute.internal`

    
**Allowed Values:**
- `ip-name`
- `resource-name`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RouteTables



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the route tables

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the route tables

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### S3

Configures S3 as destination

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">bucket_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the S3 bucket to send logs to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">log_file_format</td>
    <td><code>"plain-text"</code></td>
</tr>
<tr><td colspan="3">

The format for the flow log.

    
**Allowed Values:**
- `plain-text`
- `parquet`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_hive_compatible_s3_prefix</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">partition_logs_every_hour</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Subnets



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the subnets

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the subnets

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">owner_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the AWS account that owns the subnet

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[vpc-flow-logs-cloudwatch-service-role]: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html

[vpc-flow-logs-log-record-available-fields]: https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields

[vpc-ipam]: https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html

[vpc-network-address-usage]: https://docs.aws.amazon.com/vpc/latest/userguide/network-address-usage.html


<!-- TFDOCS_EXTRAS_END -->

## Known Limitations

### default route table

A default route table will be created by the VPC even if a main route table is set. You may delete that default route table as long as it is not set as the main route table.

### vpc_endpoint_id conflicts with destination_prefix_list_id

Specifying a route with a prefix_list_id as destination and vpc_endpoint_id as target, for example: `{ "pl-02cabcde" = "vpce-0123454fcbbabcdef" }` will return an error `vpc_endpoint_id conflicts with destination_prefix_list_id`. This is expected since the AWS API disallow this combination. VPC endpoints must be associated with the route table separately using the [aws_vpc_endpoint_route_table_association][terraform-aws-provider-aws_vpc_endpoint_route_table_association] instead.

[terraform-aws-provider-aws_vpc_endpoint_route_table_association]:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association
