# Virtual Private Cloud - Transit Gateway Module

This module creates and configures a [VPC Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html) and multiple attachments and route tables

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
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-vpc-transit-gateway.git?ref=v1.0.0"

  name = "demo-transit-gateway"

  # Manages multiple attachments
  # The keys of the map are the attachment's name
  attachments = {
    peering-connection-accepter-example = {
      peering_connection = {
        accept_connection_from = "tgw-attach-abcdef19120a8fbe5"
      }
    }
    peering-connection-requestor-example = {
      peering_connection = {
        peer_region             = "us-east-2"
        peer_transit_gateway_id = "tgw-abcdef085fe7bbdcb"
      }
    }
    vpc-attachment-example = {
      vpc = {
        vpc_id     = "vpc-abcdef4012345"
        subnet_ids = [ "subnet-abcdef17012345", "subnet-abcdef39543210" ]
      }
    }
    vpn-attachment-example = {
      vpn = {
        customer_gateway_id = "cgw-0100c0a00ffabcdef"
      }
    }
  }

  route_tables = {
    default-route-table = {
      # The keys are the destination CIDRs
      # The values are the destination attachment names
      routes = {
        "10.0.0.0/24"    = "peering-connection-requestor-example"
        "192.168.0.0/16" = "vpn-attachment-example"
      }
      attachment_associations = [ "peering-connection-accepter-example", "peering-connection-requestor-example", "vpc-attachment-example", "vpn-attachment-example" ]
      propagations            = ["peering-connection-accepter-example", "vpn-attachment-example"]
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the VPC transit gateway. All associated resources' names will also be prefixed by this value

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the VPC transit gateway

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (number) **`amazon_side_autonomous_system_numnber = 64512`** _[since v1.0.0]_

    The Autonomous System Number (ASN) for the AWS side of a Border Gateway Protocol (BGP) session

- (map(object)) **`attachments = {}`** _[since v1.0.0]_

    Manages multiple attachments. For each attachment, must specify one and only one of: `vpc`, `peering_connection`, `vpn` Please see [example](#basic-usage)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the attachment

    - (map(object)) **`flow_logs = {}`** _[since v1.0.0]_

        Configures multiple attachment level flow logs.

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

    - (object) **`peering_connection = null`** _[since v1.0.0]_

        Creates a new peering connection or accepting an incoming peering connection.

      - (string) **`accept_connection_from = null`** _[since v1.0.0]_

          The attachment ID of an incoming peering connection request. Mutually exclusive to `peer_transit_gateway_id`

      - (string) **`peer_transit_gateway_id = null`** _[since v1.0.0]_

          The ID of a remote transit gateway to request a new peering connection. Mutually exclusive to `accept_connection_from`

      - (string) **`peer_account_id = null`** _[since v1.0.0]_

          The account ID of the peer. If unspecified, the account ID of the current provider will be used

      - (string) **`peer_region = null`** _[since v1.0.0]_

          The region of the peer. If unspecified, the region of the current provider will be used

    - (object) **`vpc = null`** _[since v1.0.0]_

        Creates a VPC attachment

        - (string) **`vpc_id`** _[since v1.0.0]_

            Specify the VPC to attach to the transit gateway

        - (list(string)) **`subnet_ids`** _[since v1.0.0]_

            The subnets in which to create the transit gateway VPC attachment. You can only specify one subnet in each availability zone

        - (bool) **`enable_dns_support = true`** _[since v1.0.0]_

            Enable Domain Name System resolution for this VPC attachment.

        - (bool) **`enable_security_group_referencing_support = true`** _[since v1.0.0]_

            Enable Security Group Referencing for this VPC attachment.

        - (bool) **`enable_ipv6_support = false`** _[since v1.0.0]_

            Enable IPv6 for this attachment.

        - (bool) **`enable_appliance_mode_support = false`** _[since v1.0.0]_

            When appliance mode is enabled, traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow.

    - (object) **`vpn = null`** _[since v1.0.0]_

        Creates a VPN attachment

        - (string) **`customer_gateway_id`** _[since v1.0.0]_

            Specify the VPN customer gateway

        - (string) **`routing_options = "dynamic"`** _[since v1.0.0]_

            Specify the routing option. Valid values: `"dynamic"` (requires BGP), `"static"`.

        - (string) **`preshared_key_storage = "Standard"`** _[since v1.0.0]_

            Choose how the pre-shared key (PSK) is stored and managed. Valid values: `"Standard"` (stored in the Site-to-Site VPN service), `"SecretsManager"` (stored in AWS Secrets Manager)

        - (bool) **`enable_acceleration = false`** _[since v1.0.0]_

            Enable Acceleration improves performance of VPN tunnels via AWS Global Accelerator and the AWS global network

        - (string) **`local_ipv4_network_cidr = "0.0.0.0/0"`** _[since v1.0.0]_

            The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection.

        - (string) **`remote_ipv4_network_cidr = "0.0.0.0/0"`** _[since v1.0.0]_

            The IPv4 CIDR on the AWS side of the VPN connection.

        - (string) **`outside_ip_address_type = "PublicIpv4"`** _[since v1.0.0]_

            Specifies whether the customer gateway device is using a public or private IPv4 address. Valid values: `"PublicIpv4"`, `"PrivateIpv4"`

        - (string) **`transport_transit_gateway_attachment_id = null`** _[since v1.0.0]_

            The transport transit gateway attachment ID for the AWS Direct Connect gateway to be used for the private IP VPN connection. Only applicable if `outside_ip_address_type = "PrivateIpv4"`

      - (object) **`tunnel1_options = null`** _[since v1.0.0]_

          Configures advanced options for the first VPN tunnel

          - (string) **`dpd_timeout = "30 seconds"`** _[since v1.0.0]_

              The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher

          - (string) **`dpd_timeout_action = "clear"`** _[since v1.0.0]_

              The action to take after dead peer detection (DPD) timeout occurs. Valid values: `"clear"` (the IKE session is stopped, the tunnel goes down, and the routes are removed), `"restart"` (restart the IKE initiation), `"none"`

          - (bool) **`enable_tunnel_endpoint_lifecycle_control = false`** _[since v1.0.0]_

              Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.

          - (list(string)) **`ike_version = ["ikev1", "ikev2"]`** _[since v1.0.0]_

              List of internet key exchange (IKE) versions permitted for the VPN tunnel. Valid values: `"ikev1"`, `"ikev2"`

          - (string) **`inside_ipv4_cidr = null`** _[since v1.0.0]_

              The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified

          - (list(number)) **`phase1_dh_group_numbers = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]`** _[since v1.0.0]_

              List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations. Valid values: `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`

          - (list(string)) **`phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]`** _[since v1.0.0]_

              List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations. Valid values: `"AES128"`, `"AES256"`, `"AES128-GCM-16"`, `"AES256-GCM-16"`

          - (list(string)) **`phase1_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]`** _[since v1.0.0]_

              List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations. Valid values: `"SHA1"`, `"SHA2-256"`, `"SHA2-384"`, `"SHA2-512"`

          - (string) **`phase1_lifetime = "8 hours"`** _[since v1.0.0]_

              The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`

          - (list(number)) **`phase2_dh_group_numbers = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]`** _[since v1.0.0]_

              List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations. Valid values: `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`

          - (list(string)) **`phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]`** _[since v1.0.0]_

              List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations. Valid values: `"AES128"`, `"AES256"`, `"AES128-GCM-16"`, `"AES256-GCM-16"`

          - (list(string)) **`phase2_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]`** _[since v1.0.0]_

              List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations. Valid values: `"SHA1"`, `"SHA2-256"`, `"SHA2-384"`, `"SHA2-512"`

          - (string) **`phase2_lifetime = "1 hour"`** _[since v1.0.0]_

              The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes" - "1 hour"` and `must be less than phase1_lifetime`

          - (string) **`preshared_key = null`** _[since v1.0.0]_

              The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified

          - (number) **`rekey_fuzz_percentage = 100`** _[since v1.0.0]_

              The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`

          - (string) **`rekey_margin_time = "270 seconds"`** _[since v1.0.0]_

              The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`

          - (number) **`replay_window_size = 1024`** _[since v1.0.0]_

              The number of packets in an IKE replay window. Valid values: `64 - 2048`

          - (string) **`startup_action = "add"`** _[since v1.0.0]_

              The action to take when establishing the VPN tunnel for a new or modified VPN connection. Valid values: `"add"` (your customer gateway device must initiate the IKE negotiation and bring up the tunnel), `"start"` (AWS initiates the IKE negotiation). `"start"` is only supported for customer gateways with IP addresses.

          - (object) **`enable_tunnel_activity_log = null`** _[since v1.0.0]_

              Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.

            - (string) **`cloudwatch_log_group_arn`** _[since v1.0.0]_

                The ARN of the Cloudwatch log group to publish the logs to

            - (string) **`output_format = "json"`** _[since v1.0.0]_

                The output log's format. Valid values: `"json"`, `"text"`

      - (object) **`tunnel2_options = null`** _[since v1.0.0]_

          Configures advanced options for the second VPN tunnel

          - (string) **`dpd_timeout = "30 seconds"`** _[since v1.0.0]_

              The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher

          - (string) **`dpd_timeout_action = "clear"`** _[since v1.0.0]_

              The action to take after dead peer detection (DPD) timeout occurs. Valid values: `"clear"` (the IKE session is stopped, the tunnel goes down, and the routes are removed), `"restart"` (restart the IKE initiation), `"none"`

          - (bool) **`enable_tunnel_endpoint_lifecycle_control = false`** _[since v1.0.0]_

              Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.

          - (list(string)) **`ike_version = ["ikev1", "ikev2"]`** _[since v1.0.0]_

              List of internet key exchange (IKE) versions permitted for the VPN tunnel. Valid values: `"ikev1"`, `"ikev2"`

          - (string) **`inside_ipv4_cidr = null`** _[since v1.0.0]_

              The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified

          - (list(number)) **`phase1_dh_group_numbers = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]`** _[since v1.0.0]_

              List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations. Valid values: `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`

          - (list(string)) **`phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]`** _[since v1.0.0]_

              List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations. Valid values: `"AES128"`, `"AES256"`, `"AES128-GCM-16"`, `"AES256-GCM-16"`

          - (list(string)) **`phase1_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]`** _[since v1.0.0]_

              List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations. Valid values: `"SHA1"`, `"SHA2-256"`, `"SHA2-384"`, `"SHA2-512"`

          - (string) **`phase1_lifetime = "8 hours"`** _[since v1.0.0]_

              The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`

          - (list(number)) **`phase2_dh_group_numbers = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]`** _[since v1.0.0]_

              List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations. Valid values: `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`

          - (list(string)) **`phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]`** _[since v1.0.0]_

              List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations. Valid values: `"AES128"`, `"AES256"`, `"AES128-GCM-16"`, `"AES256-GCM-16"`

          - (list(string)) **`phase2_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]`** _[since v1.0.0]_

              List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations. Valid values: `"SHA1"`, `"SHA2-256"`, `"SHA2-384"`, `"SHA2-512"`

          - (string) **`phase2_lifetime = "1 hour"`** _[since v1.0.0]_

              The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes" - "1 hour"` and `must be less than phase1_lifetime`

          - (string) **`preshared_key = null`** _[since v1.0.0]_

              The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified

          - (number) **`rekey_fuzz_percentage = 100`** _[since v1.0.0]_

              The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`

          - (string) **`rekey_margin_time = "270 seconds"`** _[since v1.0.0]_

              The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`

          - (number) **`replay_window_size = 1024`** _[since v1.0.0]_

              The number of packets in an IKE replay window. Valid values: `64 - 2048`

          - (string) **`startup_action = "add"`** _[since v1.0.0]_

              The action to take when establishing the VPN tunnel for a new or modified VPN connection. Valid values: `"add"` (your customer gateway device must initiate the IKE negotiation and bring up the tunnel), `"start"` (AWS initiates the IKE negotiation). `"start"` is only supported for customer gateways with IP addresses.

          - (object) **`enable_tunnel_activity_log = null`** _[since v1.0.0]_

              Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.

            - (string) **`cloudwatch_log_group_arn`** _[since v1.0.0]_

                The ARN of the Cloudwatch log group to publish the logs to

            - (string) **`output_format = "json"`** _[since v1.0.0]_

                The output log's format. Valid values: `"json"`, `"text"`

- (string) **`description = null`** _[since v1.0.0]_

    The description of the transit gateway

- (bool) **`enable_dns_support = true`** _[since v1.0.0]_

    Enable Domain Name System resolution for VPCs attached to this transit gateway.

- (bool) **`enable_security_group_referencing_support = false`** _[since v1.0.0]_

    Enable Security Group referencing for VPCs attached to this transit gateway.

- (bool) **`enable_vpn_ecmp_support = true`** _[since v1.0.0]_

    Enable equal cost multipath (ECMP) routing for VPN Connections that are attached to this transit gateway.

- (bool) **`enable_default_route_table_association = true`** _[since v1.0.0]_

    Automatically associate transit gateway attachments with this transit gateway's default route table.

- (bool) **`enable_default_route_table_propagation = true`** _[since v1.0.0]_

    Automatically propagate transit gateway attachments with this transit gateway's default route table.

- (bool) **`enable_multicast_support = false`** _[since v1.0.0]_

    Enables the ability to create multicast domains in this transit gateway.

- (bool) **`auto_accept_shared_attachments = false`** _[since v1.0.0]_

    Automatically accept cross-account attachments that are attached to this transit gateway.

- (list(string)) **`cidr_blocks = null`** _[since v1.0.0]_

    You can associate any public or private IP address range, except for addresses in the 169.254.0.0/16 range, and ranges that overlap with the addresses for your VPC attachments and on-premises networks.

- (map(object)) **`flow_logs = {}`** _[since v1.0.0]_

    Configures multiple Transit gateway level flow logs.

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

- (map(object)) **`route_tables = {}`** _[since v1.0.0]_

    Manages multiple route tables. Please see [example](#basic-usage)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the route table

    - (map(string)) **`routes = {}`** _[since v1.0.0]_

        Map of routes in the `{ <route_destination> = <attachment_name> }` format

    - (list(string)) **`attachment_associations = []`** _[since v1.0.0]_

        List of attachment names this route table is associated to

    - (list(string)) **`propagations = []`** _[since v1.0.0]_

        List of attachment names to propagate routes to this route table

## Outputs

- (object) **`transit_gateway`** _[since v1.0.0]_

    Transit gateway

    - (string) **`arn`** _[since v1.0.0]_

        The ARN of the transit gateway

    - (string) **`association_default_route_table_id`** _[since v1.0.0]_

        Identifier of the default association route table

    - (string) **`id`** _[since v1.0.0]_

        The ID of the transit gateway

    - (string) **`owner_id`** _[since v1.0.0]_

        Identifier of the AWS account that owns the EC2 Transit Gateway

    - (string) **`propagation_default_route_table_id`** _[since v1.0.0]_

        Identifier of the default propagation route table

[vpc-flow-logs-cloudwatch-service-role]:https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html
[vpc-flow-logs-log-record-available-fields]:https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields
