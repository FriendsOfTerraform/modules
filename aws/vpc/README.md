# Virtual Private Cloud Module

This module creates and configures a [VPC](https://aws.amazon.com/vpc/) and multiple subnets, route tables, and gateways

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Flow Logs](#flow-logs)
    - [Peering Connection Requests](#peering-connection-requests)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
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

## Argument Reference

### Mandatory

- (object) **`cidr_block`** _[since v1.0.0]_

    Configures the VPC CIDR block

    - (object) **`ipv4 = null`** _[since v1.0.0]_

        Configures the IPv4 CIDR block

        - (string) **`cidr = null`** _[since v1.0.0]_

            Manually input an IPv4 CIDR. The CIDR block size must have a size between /16 and /28. Mutually exclusive to `ipam`

        - (object) **`ipam = null`** _[since v1.0.0]_

            Specify an [Amazon VPC IP Address Manager (IPAM)][vpc-ipam] pool to obtain an IPv4 CIDR automatically. If you select an IPAM pool, the size of the CIDR is limited by the allocation rules on the IPAM pool (allowed minimum, allowed maximum, and default). Mutally exclusive to `cidr`

            - (string) **`pool_id`** _[since v1.0.0]_

                The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR

            - (string) **`netmask`** _[since v1.0.0]_

                The netmask length of the IPv4 CIDR you want to allocate to this VPC

- (string) **`name`** _[since v1.0.0]_

    The name of the VPC. All associated resources will also have their name prefixed with this value

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the VPC

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (bool) **`create_nat_gateways = false`** _[since v1.0.0]_

    If enabled, one NAT gateway will be created on the first public subnets in each availability zone. You can then refer to them on the route table with `default-nat-gateway/<availability_zone_name>`. Please see [example](#basic-usage)

- (object) **`dhcp_options = null`** _[since v1.0.0]_

    DHCP option sets give you control over various aspects of routing in your virtual network, such as the DNS servers, domain names, or Network Time Protocol (NTP) servers used by the devices in your VPC. The Amazon default option set will be used if not specified

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the option set

    - (string) **`domain_name = null`** _[since v1.0.0]_

        If you're using `AmazonProvidedDNS` in `us-east-1`, specify `ec2.internal`. If you're using `AmazonProvidedDNS` in another region, specify `region.compute.internal` (for example, `ap-northeast-1.compute.internal`). Otherwise, specify a domain name (for example, example.com). This value is used to complete unqualified DNS hostnames.

    - (list(string)) **`domain_name_servers = ["AmazonProvidedDNS"]`** _[since v1.0.0]_

        The IP addresses of up to four domain name servers, or AmazonProvidedDNS. Although you can specify up to four domain name servers, note that some operating systems may impose lower limits. If you want your instance to receive a custom DNS hostname as specified in domain-name, you must set domain-name-servers to a custom DNS server.

    - (list(string)) **`ntp_servers = null`** _[since v1.0.0]_

        The IP addresses of up to four NTP servers

    - (list(string)) **`netbios_name_servers = null`** _[since v1.0.0]_

        The IP addresses of up to four NetBIOS name servers

    - (number) **`netbios_node_type = null`** _[since v1.0.0]_

        The NetBIOS node type (`1`, `2`, `4`, or `8`). AWS recommends to specify `2` since broadcast and multicast are not supported in their network.

- (object) **`dns_settings = {}`** _[since v1.0.0]_

    Configures DNS settings for the VPC

    - (bool) **`enable_dns_resolution = true`** _[since v1.0.0]_

        Whether DNS resolution through the Amazon DNS server is supported for the VPC

    - (bool) **`enable_dns_hostnames = false`** _[since v1.0.0]_

        Whether instances launched in the VPC receive public DNS hostnames that correspond to their public IP addresses

- (bool) **`enable_network_address_usage_metrics = false`** _[since v1.0.0]_

    [Network Address Usage (NAU)][vpc-network-address-usage] is a metric applied to resources in your virtual network to help you plan for and monitor the size of your VPC

- (map(object)) **`flow_logs = {}`** _[since v1.0.0]_

    Configures multiple VPC level flow logs. Please see [example](#flow-logs)

    - (object) **`destination`** _[since v1.0.0]_

        Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`

        - (object) **`cloudwatch_logs = null`** _[since v1.0.0]_

            Configures CloudWatch Logs as destination

            - (string) **`log_group_arn`** _[since v1.0.0]_

                The ARN of the CloudWatch log group to send logs to

            - (string) **`service_role_arn = null`** _[since v1.0.0]_

                Arn of an IAM role that [gives permission to flow logs to send logs to CloudWatch][vpc-flow-logs-cloudwatch-service-role]. A default service role will be created if not specified

        - (object) **`s3 = null`** _[since v1.0.0]_

            Configures S3 as destination

            - (string) **`bucket_arn`** _[since v1.0.0]_

                The ARN of the S3 bucket to send logs to

            - (string) **`log_file_format = "plain-text"`** _[since v1.0.0]_

                The format for the flow log. Valid values: `"plain-text"`, `"parquet"`

            - (bool) **`enable_hive_compatible_s3_prefix = false`** _[since v1.0.0]_

                Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3

            - (bool) **`partition_logs_every_hour = false`** _[since v1.0.0]_

                Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries.

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the flow log

    - (string) **`custom_log_record_format = null`** _[since v1.0.0]_

        The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields

    - (string) **`filter = "ALL"`** _[since v1.0.0]_

        The type of traffic to capture. Valid values: `"ALL"`, `"ACCEPT"`, `"REJECT"`

    - (number) **`maximum_aggregation_interval = 600`** _[since v1.0.0]_

        The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60 `seconds (1 minute) or `600` seconds (10 minutes).

- (map(object)) **`peering_connection_requests = {}`** _[since v1.0.0]_

    Manages multiple VPC peering connection requests. Please see [example](#peering-connection-requests)

    - (string) **`peer_vpc_id`** _[since v1.0.0]_

        The ID of the target VPC with which you are creating the VPC Peering Connection

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the peering connection request

    - (bool) **`allow_remote_vpc_dns_resolution = false`** _[since v1.0.0]_

        Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. To use DNS resolution over peering you must enable DNS Hostname on both the requester's and accepter's VPC

    - (string) **`peer_account_id = null`** _[since v1.0.0]_

        The AWS account ID of the target peer VPC. Defaults to the current account if unspecified.

    - (string) **`peer_region = null`** _[since v1.0.0]_

        The region of the accepter VPC of the VPC Peering Connection. Defaults to the current region if unspecified.

- (map(object)) **`route_tables = {}`** _[since v1.0.0]_

    Manages multiple route tables. Please see [example](#basic-usage)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the route table

    - (bool) **`main_route_table = false`** _[since v1.1.0]_

        Weather this is the main route table. You may only set one route table as the main route table

    - (map(string)) **`routes = {}`** _[since v1.0.0]_

        Map of routes in the `{ <route_destination> = <route_target> }` format

    - (list(string)) **`subnet_associations = []`** _[since v1.0.0]_

        List of subnet names this route table is associated to

- (map(object)) **`subnets = {}`** _[since v1.0.0]_

    Manages multiple subnets. [See example](#basic-usage)

    - (string) **`availability_zone`** _[since v1.0.0]_

        Availability zone of the subnet

    - (string) **`ipv4_cidr_block`** _[since v1.0.0]_

        The IPv4 CIDR block for the subnet

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the subnet

    - (bool) **`enable_auto_assign_public_ipv4_address = false`** _[since v1.0.0]_

        If true, instances launched into the subnet should be assigned a public IP address. The subnet will also be considered a public subnet and an internet gateway will be created for the VPC.

    - (map(object)) **`flow_logs = {}`** _[since v1.0.0]_

        Configures multiple subnet level flow logs. Please see [example](#flow-logs)

        - (object) **`destination`** _[since v1.0.0]_

            Where the flow log will be sent to. Must specify only one of the following: `cloudwatch_logs`, `s3`

            - (object) **`cloudwatch_logs = null`** _[since v1.0.0]_

                Configures CloudWatch Logs as destination

                - (string) **`log_group_arn`** _[since v1.0.0]_

                    The ARN of the CloudWatch log group to send logs to

                - (string) **`service_role_arn = null`** _[since v1.0.0]_

                    Arn of an IAM role that [gives permission to flow logs to send logs to CloudWatch][vpc-flow-logs-cloudwatch-service-role]. A default service role will be created if not specified

            - (object) **`s3 = null`** _[since v1.0.0]_

                Configures S3 as destination

                - (string) **`bucket_arn`** _[since v1.0.0]_

                    The ARN of the S3 bucket to send logs to

                - (string) **`log_file_format = "plain-text"`** _[since v1.0.0]_

                    The format for the flow log. Valid values: `"plain-text"`, `"parquet"`

                - (bool) **`enable_hive_compatible_s3_prefix = false`** _[since v1.0.0]_

                    Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3

                - (bool) **`partition_logs_every_hour = false`** _[since v1.0.0]_

                    Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries.

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags for the flow log

        - (string) **`custom_log_record_format = null`** _[since v1.0.0]_

            The fields to include in the flow log record. Accepted format example: `"$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"`. Please refer to [this documentation][vpc-flow-logs-log-record-available-fields] for a list of available fields

        - (string) **`filter = "ALL"`** _[since v1.0.0]_

            The type of traffic to capture. Valid values: `"ALL"`, `"ACCEPT"`, `"REJECT"`

        - (number) **`maximum_aggregation_interval = 600`** _[since v1.0.0]_

            The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60 `seconds (1 minute) or `600` seconds (10 minutes).

    - (object) **`resource_based_name_settings = {}`** _[since v1.0.0]_

        Specify the hostname type for EC2 instances in this subnet and optional RBN DNS query settings

        - (bool) **`enable_resource_name_dns_a_record_on_launch = false`** _[since v1.0.0]_

            Choose if DNS A record queries for the resource-based name should return the IPv4 address or not

        - (string) **`hostname_type = "ip-name"`** _[since v1.0.0]_

            Determines if the guest OS hostname of EC2 instances in this subnet should be based on the resource name (RBN) or the IP name (IPBN). Valid values: `"ip-name"`, `"resource-name"`. If you choose `"resource-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use the EC2 instance ID: `ec2-instance-id.region.compute.internal`. If you choose `"ip-name"`, when you launch an EC2 instance in this subnet, the guest OS hostname of the EC2 instance will be configured to use an IP-based name: `private-ipv4-address.region.compute.internal`

- (string) **`tenancy = "default"`** _[since v1.0.0]_

    Specify the VPC's tenancy. Valid values: `"default"`, `"dedicated"`

## Outputs

- (object) **`dhcp_options`** _[since v1.0.0]_

    DHCP option

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the DHCP option

    - (string) **`id`** _[since v1.0.0]_

        The ID of the DHCP option

- (object) **`internet_gateway`** _[since v1.0.0]_

    The default internet gateway

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the internet gateway

    - (string) **`id`** _[since v1.0.0]_

        The ID of the internet gateway

    - (string) **`owner_id`** _[since v1.0.0]_

        The ID of the AWS account that owns the internet gateway

- (map(object)) **`nat_gateways`** _[since v1.0.0]_

    Map of default NAT gateways. The key of the map is the NAT gateway's name

    - (string) **`availability_zone`** _[since v1.0.0]_

        The availability of the NAT gateway

    - (string) **`association_id`** _[since v1.0.0]_

        The association ID of the Elastic IP address that's associated with the NAT Gateway

    - (string) **`id`** _[since v1.0.0]_

        The ID of the NAT gateway

    - (string) **`network_interface_id`** _[since v1.0.0]_

        The ID of the network interface associated with the NAT Gateway

    - (string) **`public_ip`** _[since v1.0.0]_

        The Elastic IP address associated with the NAT Gateway

- (map(object)) **`peering_connection_requests`** _[since v1.0.0]_

    Map of peering connection requests. The key of the map is the peering connection request's name

    - (string) **`id`** _[since v1.0.0]_

        The peering connection ID

    - (string) **`accept_status`** _[since v1.0.0]_

        The status of the VPC Peering Connection request

- (map(object)) **`route_tables`** _[since v1.0.0]_

    Map of route tables. The key of the map is the route table's name

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the route tables

    - (string) **`id`** _[since v1.0.0]_

        The ID of the route tables

- (map(object)) **`subnets`** _[since v1.0.0]_

    Map of subnets. The key of the map is the subnet's name

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the subnets

    - (string) **`id`** _[since v1.0.0]_

        The ID of the subnets

    - (string) **`owner_id`** _[since v1.0.0]_

        The ID of the AWS account that owns the subnet

- (string) **`vpc_arn`** _[since v1.0.0]_

    The ARN of the VPC

- (string) **`vpc_id`** _[since v1.0.0]_

    The ID of the VPC

## Known Limitations

### default route table

A default route table will be created by the VPC even if a main route table is set. You may delete that default route table as long as it is not set as the main route table.

### vpc_endpoint_id conflicts with destination_prefix_list_id

Specifying a route with a prefix_list_id as destination and vpc_endpoint_id as target, for example: `{ "pl-02cabcde" = "vpce-0123454fcbbabcdef" }` will return an error `vpc_endpoint_id conflicts with destination_prefix_list_id`. This is expected since the AWS API disallow this combination. VPC endpoints must be associated with the route table separately using the [aws_vpc_endpoint_route_table_association][terraform-aws-provider-aws_vpc_endpoint_route_table_association] instead.

[terraform-aws-provider-aws_vpc_endpoint_route_table_association]:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association
[vpc-flow-logs-cloudwatch-service-role]:https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html
[vpc-flow-logs-log-record-available-fields]:https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields
[vpc-ipam]:https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html
[vpc-network-address-usage]:https://docs.aws.amazon.com/vpc/latest/userguide/network-address-usage.html
