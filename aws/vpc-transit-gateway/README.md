# Virtual Private Cloud - Transit Gateway Module

This module creates and configures a [VPC Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html) and multiple attachments and route tables

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

The name of the VPC transit gateway. All associated resources' names will also be prefixed by this value

    

    

    

    

    
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

Additional tags for the VPC transit gateway

    

    

    

    

    
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
    <td><code>number</code></td>
    <td width="100%">amazon_side_autonomous_system_numnber</td>
    <td><code>64512</code></td>
</tr>
<tr><td colspan="3">

The Autonomous System Number (ASN) for the AWS side of a Border Gateway Protocol (BGP) session

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#attachments">Attachments</a>))</code></td>
    <td width="100%">attachments</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple attachments. For each attachment, must specify one and only one of: `vpc`, `peering_connection`, `vpn`.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">auto_accept_shared_attachments</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Automatically accept cross-account attachments that are attached to this transit gateway.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">cidr_blocks</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

You can associate any public or private IP address range, except for addresses in the 169.254.0.0/16 range, and ranges that overlap with the addresses for your VPC attachments and on-premises networks.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the transit gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_default_route_table_association</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Automatically associate transit gateway attachments with this transit gateway's default route table.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_default_route_table_propagation</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Automatically propagate transit gateway attachments with this transit gateway's default route table.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_dns_support</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enable Domain Name System resolution for VPCs attached to this transit gateway.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_multicast_support</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables the ability to create multicast domains in this transit gateway.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_security_group_referencing_support</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enable Security Group referencing for VPCs attached to this transit gateway.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_vpn_ecmp_support</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enable equal cost multipath (ECMP) routing for VPN Connections that are attached to this transit gateway.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#flowlogs">FlowLogs</a>))</code></td>
    <td width="100%">flow_logs</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple Transit gateway level flow logs.

    

    

    

    

    
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
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#transitgateway">TransitGateway</a>)</code></td>
    <td width="100%">transit_gateway</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transit gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### Attachments



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the attachment

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#flowlogs">FlowLogs</a>))</code></td>
    <td width="100%">flow_logs</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple attachment level flow logs.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#peeringconnection">PeeringConnection</a>)</code></td>
    <td width="100%">peering_connection</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a new peering connection or accepting an incoming peering connection.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#vpc">Vpc</a>)</code></td>
    <td width="100%">vpc</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a VPC attachment

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#vpn">Vpn</a>)</code></td>
    <td width="100%">vpn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a VPN attachment

    

    

    

    

    
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



#### EnableTunnelActivityLog

Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cloudwatch_log_group_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the Cloudwatch log group to publish the logs to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">output_format</td>
    <td><code>"json"</code></td>
</tr>
<tr><td colspan="3">

The output log's format.

    
**Allowed Values:**
- `json`
- `text`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### FlowLogs



    

    

    

    

    
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
</tbody></table>



#### PeeringConnection

Creates a new peering connection or accepting an incoming peering connection.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">accept_connection_from</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The attachment ID of an incoming peering connection request. Mutually exclusive to `peer_transit_gateway_id`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">peer_transit_gateway_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of a remote transit gateway to request a new peering connection. Mutually exclusive to `accept_connection_from`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">peer_account_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The account ID of the peer. If unspecified, the account ID of the current provider will be used

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">peer_region</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The region of the peer. If unspecified, the region of the current provider will be used

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RouteTables



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the route table

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">routes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Map of routes in the `{ <route_destination> = <attachment_name> }` format

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">attachment_associations</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of attachment names this route table is associated to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">propagations</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of attachment names to propagate routes to this route table

    

    

    

    

    
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



#### TransitGateway



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the transit gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">association_default_route_table_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Identifier of the default association route table

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the transit gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">owner_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Identifier of the AWS account that owns the EC2 Transit Gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">propagation_default_route_table_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Identifier of the default propagation route table

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Tunnel1Options

Configures advanced options for the first VPN tunnel

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">dpd_timeout</td>
    <td><code>"30 seconds"</code></td>
</tr>
<tr><td colspan="3">

The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dpd_timeout_action</td>
    <td><code>"clear"</code></td>
</tr>
<tr><td colspan="3">

The action to take after dead peer detection (DPD) timeout occurs.

- `clear`: the IKE session is stopped, the tunnel goes down, and the routes are removed
- `restart`: restart the IKE initiation

    
**Allowed Values:**
- `clear`
- `restart`
- `none`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_tunnel_endpoint_lifecycle_control</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">ike_version</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of internet key exchange (IKE) versions permitted for the VPN tunnel.

    
**Allowed Values:**
- `ikev1`
- `ikev2`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">inside_ipv4_cidr</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(number)</code></td>
    <td width="100%">phase1_dh_group_numbers</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `2`
- `5`
- `14`
- `15`
- `16`
- `17`
- `18`
- `19`
- `20`
- `21`
- `22`
- `23`
- `24`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase1_encryption_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `AES128`
- `AES256`
- `AES128-GCM-16`
- `AES256-GCM-16`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase1_integrity_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `SHA1`
- `SHA2-256`
- `SHA2-384`
- `SHA2-512`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">phase1_lifetime</td>
    <td><code>"8 hours"</code></td>
</tr>
<tr><td colspan="3">

The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(number)</code></td>
    <td width="100%">phase2_dh_group_numbers</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `2`
- `5`
- `14`
- `15`
- `16`
- `17`
- `18`
- `19`
- `20`
- `21`
- `22`
- `23`
- `24`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase2_encryption_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `AES128`
- `AES256`
- `AES128-GCM-16`
- `AES256-GCM-16`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase2_integrity_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `SHA1`
- `SHA2-256`
- `SHA2-384`
- `SHA2-512`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">phase2_lifetime</td>
    <td><code>"1 hour"</code></td>
</tr>
<tr><td colspan="3">

The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes"` - `"1 hour"` and must be less than `phase1_lifetime`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">preshared_key</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">rekey_fuzz_percentage</td>
    <td><code>100</code></td>
</tr>
<tr><td colspan="3">

The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">rekey_margin_time</td>
    <td><code>"270 seconds"</code></td>
</tr>
<tr><td colspan="3">

The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">replay_window_size</td>
    <td><code>1024</code></td>
</tr>
<tr><td colspan="3">

The number of packets in an IKE replay window. Valid values: `64 - 2048`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">startup_action</td>
    <td><code>"add"</code></td>
</tr>
<tr><td colspan="3">

The action to take when establishing the VPN tunnel for a new or modified VPN connection. `start` is only supported for customer gateways with IP addresses.

- `add`: your customer gateway device must initiate the IKE negotiation and bring up the tunnel
- `start`: AWS initiates the IKE negotiation

    
**Allowed Values:**
- `add`
- `start`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enabletunnelactivitylog">EnableTunnelActivityLog</a>)</code></td>
    <td width="100%">enable_tunnel_activity_log</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Tunnel2Options

Configures advanced options for the second VPN tunnel

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">dpd_timeout</td>
    <td><code>"30 seconds"</code></td>
</tr>
<tr><td colspan="3">

The time after which a DPD timeout occurs. Must be `"30 seconds"` or higher

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dpd_timeout_action</td>
    <td><code>"clear"</code></td>
</tr>
<tr><td colspan="3">

The action to take after dead peer detection (DPD) timeout occurs.

- `clear`: the IKE session is stopped, the tunnel goes down, and the routes are removed
- `restart`: restart the IKE initiation

    
**Allowed Values:**
- `clear`
- `restart`
- `none`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_tunnel_endpoint_lifecycle_control</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">ike_version</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of internet key exchange (IKE) versions permitted for the VPN tunnel.

    
**Allowed Values:**
- `ikev1`
- `ikev2`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">inside_ipv4_cidr</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The CIDR block of the inside IP addresses for the VPN tunnel. Valid value is a size /30 CIDR block from the 169.254.0.0/16 range. One will be generated by AWS if not specified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(number)</code></td>
    <td width="100%">phase1_dh_group_numbers</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `2`
- `5`
- `14`
- `15`
- `16`
- `17`
- `18`
- `19`
- `20`
- `21`
- `22`
- `23`
- `24`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase1_encryption_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted encryption algorithms for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `AES128`
- `AES256`
- `AES128-GCM-16`
- `AES256-GCM-16`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase1_integrity_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted integrity algorithms for the VPN tunnel for phase 1 IKE negotiations.

    
**Allowed Values:**
- `SHA1`
- `SHA2-256`
- `SHA2-384`
- `SHA2-512`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">phase1_lifetime</td>
    <td><code>"8 hours"</code></td>
</tr>
<tr><td colspan="3">

The lifetime for phase 1 of the IKE negotiation. Valid values: `"15 minutes" - "8 hours"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(number)</code></td>
    <td width="100%">phase2_dh_group_numbers</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted Diffie-Hellman group numbers for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `2`
- `5`
- `14`
- `15`
- `16`
- `17`
- `18`
- `19`
- `20`
- `21`
- `22`
- `23`
- `24`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase2_encryption_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted encryption algorithms for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `AES128`
- `AES256`
- `AES128-GCM-16`
- `AES256-GCM-16`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">phase2_integrity_algorithms</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of permitted integrity algorithms for the VPN tunnel for phase 2 IKE negotiations.

    
**Allowed Values:**
- `SHA1`
- `SHA2-256`
- `SHA2-384`
- `SHA2-512`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">phase2_lifetime</td>
    <td><code>"1 hour"</code></td>
</tr>
<tr><td colspan="3">

The lifetime for phase 2 of the IKE negotiation. Valid values: `"15 minutes"` - `"1 hour"` and must be less than `phase1_lifetime`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">preshared_key</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The pre-shared key (PSK) to establish initial authentication between the virtual private gateway and customer gateway. One will be generated by AWS if unspecified

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">rekey_fuzz_percentage</td>
    <td><code>100</code></td>
</tr>
<tr><td colspan="3">

The percentage of the rekey window during which the rekey time is randomly selected. Valid values: `0 - 100`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">rekey_margin_time</td>
    <td><code>"270 seconds"</code></td>
</tr>
<tr><td colspan="3">

The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. `"60 seconds" - phase2_lifetime/2`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">replay_window_size</td>
    <td><code>1024</code></td>
</tr>
<tr><td colspan="3">

The number of packets in an IKE replay window. Valid values: `64` - `2048`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">startup_action</td>
    <td><code>"add"</code></td>
</tr>
<tr><td colspan="3">

The action to take when establishing the VPN tunnel for a new or modified VPN connection. `"start"` is only supported for customer gateways with IP addresses.

- `add`: your customer gateway device must initiate the IKE negotiation and bring up the tunnel
- `start`: AWS initiates the IKE negotiation

    
**Allowed Values:**
- `add`
- `start`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enabletunnelactivitylog">EnableTunnelActivityLog</a>)</code></td>
    <td width="100%">enable_tunnel_activity_log</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Tunnel activity log captures log messages for IPsec activity and DPD protocol messages.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Vpc

Creates a VPC attachment

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">vpc_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the VPC to attach to the transit gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

The subnets in which to create the transit gateway VPC attachment. You can only specify one subnet in each availability zone

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_dns_support</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enable Domain Name System resolution for this VPC attachment.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_security_group_referencing_support</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enable Security Group Referencing for this VPC attachment.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_ipv6_support</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enable IPv6 for this attachment.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_appliance_mode_support</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

When appliance mode is enabled, traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Vpn

Creates a VPN attachment

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">customer_gateway_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the VPN customer gateway

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">routing_options</td>
    <td><code>"dynamic"</code></td>
</tr>
<tr><td colspan="3">

Specify the routing option. Note: `dynamic` requires BGP.

    
**Allowed Values:**
- `dynamic`
- `static`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">preshared_key_storage</td>
    <td><code>"Standard"</code></td>
</tr>
<tr><td colspan="3">

Choose how the pre-shared key (PSK) is stored and managed.

- `Standard`: stored in the Site-to-Site VPN service
- `SecretsManager`: stored in AWS Secrets Manager

    
**Allowed Values:**
- `Standard`
- `SecretsManager`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_acceleration</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enable Acceleration improves performance of VPN tunnels via AWS Global Accelerator and the AWS global network

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">local_ipv4_network_cidr</td>
    <td><code>"0.0.0.0/0"</code></td>
</tr>
<tr><td colspan="3">

The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">remote_ipv4_network_cidr</td>
    <td><code>"0.0.0.0/0"</code></td>
</tr>
<tr><td colspan="3">

The IPv4 CIDR on the AWS side of the VPN connection.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">outside_ip_address_type</td>
    <td><code>"PublicIpv4"</code></td>
</tr>
<tr><td colspan="3">

Specifies whether the customer gateway device is using a public or private IPv4 address.

    
**Allowed Values:**
- `PublicIpv4`
- `PrivateIpv4`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">transport_transit_gateway_attachment_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The transport transit gateway attachment ID for the AWS Direct Connect gateway to be used for the private IP VPN connection. Only applicable if `outside_ip_address_type = "PrivateIpv4"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#tunnel1options">Tunnel1Options</a>)</code></td>
    <td width="100%">tunnel1_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures advanced options for the first VPN tunnel

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#tunnel2options">Tunnel2Options</a>)</code></td>
    <td width="100%">tunnel2_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures advanced options for the second VPN tunnel

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[vpc-flow-logs-cloudwatch-service-role]: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-iam-role.html

[vpc-flow-logs-log-record-available-fields]: https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields


<!-- TFDOCS_EXTRAS_END -->
