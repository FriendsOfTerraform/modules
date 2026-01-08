# Route 53 Module

This module configures an Amazon [Route 53](https://aws.amazon.com/route53/) hosted zone with multiple records

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Private Hosted Zone](#private-hosted-zone)
  - [DNSSEC](#dnssec)
  - [Failover Routing Policy](#failover-routing-policy)
  - [Geolocation Routing Policy](#geolocation-routing-policy)
  - [Geoproximity Routing Policy](#geoproximity-routing-policy)
  - [Latency-based Routing Policy](#latency-based-routing-policy)
  - [Multivalue Answer Routing Policy](#multivalue-answer-routing-policy)
  - [Weighted Routing Policy](#weighted-routing-policy)
  - [Health Check](#health-check)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
  - [Objects](#objects)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
  - [Managing Cross-Account VPC Associations](#managing-cross-account-vpc-associations)

## Example Usage

### Basic Usage

This example creates a hosted zone psin-lab.com and several records

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  # Manages multiple records
  records = [
    # non-alias record
    # www.psin-lab.com
    {
      name   = "www"
      type   = "A"
      values = ["8.8.8.8"]
    },

    # alias record
    # portal.psin-lab.com
    {
      name = "portal"
      type = "A"

      alias = {
        target         = "abcdef1234aabbccddeea112233e267a-4d0943c56b90056b.elb.us-west-1.amazonaws.com"
        hosted_zone_id = "Z24FKFUX50B4VW"
      }
    }
  ]
}
```

### Private Hosted Zone

This example creates a private hosted zone psin-lab.local

```terraform
module "psin_lab_local" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.local"
  
  # This association will be managed by the VPC block in the aws_route53_zone resource
  # The VPC block will then be ignored for any changes going forward
  # The VPC block is required in order to create a private hosted zone
  # Use private_zone_vpc_associations for all additional zone associations
  # Please read the Managing Cross-Account VPC Associations under Known Limitations for more details
  primary_private_zone_vpc_association = { vpc_id = "vpc-abcdef012345" } 

  # Resolve DNS queries for these associated VPCs
  private_zone_vpc_associations = {
    "us-east-2" = [
      "vpc-08b9cfbabcde12345", # EKS VPC
      "vpc-0fe6905abcde12345"  # Team A VPC
    ]

    "us-west-1" = [
      "vpc-049fc30abcde12345" # EKS VPC
    ]
  }

  ########################################################################
  # To associate this private hosted zone to VPCs from external accounts #
  ########################################################################
  vpc_association_authorizations = ["vpc-01234567898fc2074"] # private subnet from account 2

  # You must complete the associate in the external account after the authorization is created
  resource "aws_route53_zone_association" "account2_private_vpc" {
    provider = aws.account2

    vpc_id  = "vpc-01234567898fc2074"
    zone_id = module.psin_lab_local.route53_hosted_zone_id
  }
}
```

### DNSSEC

This example demonstrates how to enable DNSSEC signing by using a default KSK. After enabling DNSSEC signing, you must follow this [instructions here][route53-dnssec-chain-of-trust] to create the DS record in the parent zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  # enable DNSSEC signing
  enable_dnssec = {
    # You can manage up to two KSK at once for key rotation purposes
    # The keys of the map will be the KSK and the generated KMS' name
    key_signing_keys = {
      # Creates a KSK with default settings
      "psin-lab-com-ksk-01" = {}
    }
  }
}
```

### Failover Routing Policy

This example demonstrates the [Failover Routing Policy][route53-routing-policy-failover] to configure active-passive failover. You can use failover routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name           = "www"
      set_identifier = "primary"
      type           = "A"
      values         = ["1.1.1.1"]

      # Traffic are routed to the primary record as long as it is healthy
      failover_routing_policy = {
        failover_record_type = "PRIMARY"
      }

      # health check
      health_check = {
        endpoint_check = {
          url      = "https://1.1.1.1/healthz"
          hostname = "www"
        }
      }
    },
    {
      name           = "www"
      set_identifier = "secondary"
      type           = "A"
      values         = ["8.8.8.8"]

      # Traffic are routed to the secondary record when primary becomes unhealthy
      failover_routing_policy = {
        failover_record_type = "SECONDARY"
      }
    }
  ]
}
```

### Geolocation Routing Policy

This example demonstrates the [Geolocation Routing Policy][route53-routing-policy-geolocation] to route traffic based on the location of your users. You can use geolocation routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name           = "www"
      set_identifier = "California"
      type           = "A"
      values         = ["1.1.1.1"]

      # Route incoming traffic from California (a state of the US) to this record
      geolocation_routing_policy = {
        location = "California"
      }
    },
    {
      name           = "www"
      set_identifier = "HongKong"
      type           = "A"
      values         = ["8.8.8.8"]

      # Route incoming traffic from Hong Kong (a country) to this record
      geolocation_routing_policy = {
        location = "Hong Kong"
      }
    },
    {
      name           = "www"
      set_identifier = "VinnytskaOblast"
      type           = "A"
      values         = ["2.2.2.2"]

      # Route incoming traffic from Vinnytska Oblast (a subdivision of Ukrain) to this record
      geolocation_routing_policy = {
        location = "Vinnytska Oblast"
      }
    }
  ]
}
```

### Geoproximity Routing Policy

This example demonstrates the [Geoproximity Routing Policy][route53-routing-policy-geoproximity] to route traffic based on the location of your resources and, optionally, shift traffic from resources in one location to resources in another location. You can use geoproximity routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name           = "www"
      set_identifier = "coordinates"
      type           = "A"
      values         = ["1.1.1.1"]

      # Route incoming traffic closest to the coordinate to this record
      geoproximity_routing_policy = {
        coordinates = {
          latitude  = "36.28"
          longitude = "-115.14"
        }
      }
    },
    {
      name           = "www"
      set_identifier = "localZoneGroup"
      type           = "A"
      values         = ["8.8.8.8"]

      # Route incoming traffic closest to the zone group to this record
      geoproximity_routing_policy = {
        local_zone_group = "ap-southeast-1-mnl-1" # Phillipines Manila
      }
    },
    {
      name           = "www"
      set_identifier = "region"
      type           = "A"
      values         = ["8.8.8.8"]

      # # Route incoming traffic closest to the AWS region to this record
      geoproximity_routing_policy = {
        region = "us-west-1"
      }
    }
  ]
}
```

### Latency-based Routing Policy

This example demonstrates the [Latency-based Routing Policy][route53-routing-policy-latency] to route traffic to the Region that provides the best latency when you have resources in multiple AWS Regions. You can use latency routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name           = "www"
      set_identifier = "us-west-1"
      type           = "A"
      values         = ["1.1.1.1"]

      # Route incoming traffic closest to this region to the record
      latency_routing_policy = {
        region = "us-west-1"
      }
    },
    {
      name           = "www"
      set_identifier = "us-east-2"
      type           = "A"
      values         = ["8.8.8.8"]

      # Route incoming traffic closest to this region to the record
      latency_routing_policy = {
        region = "us-east-2"
      }
    }
  ]
}
```

### Multivalue Answer Routing Policy

This example demonstrates the [Multivalue Answer Routing Policy][route53-routing-policy-multivalue-answer] to configures Route 53 to respond to DNS queries with up to eight healthy records selected at random. You can use multivalue answer routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name                             = "www"
      set_identifier                   = "MultiSet-01"
      type                             = "A"
      values                           = ["1.1.1.1"]
      multivalue_answer_routing_policy = {}

      # health check
      health_check = {
        endpoint_check = {
          url      = "https://1.1.1.1/healthz"
          hostname = "www"
        }
      }
    },
    {
      name                             = "www"
      set_identifier                   = "MultiSet-02"
      type                             = "A"
      values                           = ["8.8.8.8"]
      multivalue_answer_routing_policy = {}

      # health check
      health_check = {
        endpoint_check = {
          url      = "https://8.8.8.8/healthz"
          hostname = "www"
        }
      }
    }
  ]
}
```

### Weighted Routing Policy

This example demonstrates the [Weighted Routing Policy][route53-routing-policy-weighted] to route traffic to multiple resources in proportions that you specify. You can use weighted routing to create records in a private hosted zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    # www.psin-lab.com
    # Set identifier is required when using any routing policy besides simple (no routing policy)
    {
      name           = "www"
      set_identifier = "Blue"
      type           = "A"
      values         = ["1.1.1.1"]

      # Routes 80% of incoming traffic to Blue
      weighted_routing_policy = {
        weight = 80
      }
    },
    {
      name           = "www"
      set_identifier = "Green"
      type           = "A"
      values         = ["8.8.8.8"]

      # Routes 20% of incoming traffic to Green
      weighted_routing_policy = {
        weight = 20
      }
    }
  ]
}
```

### Health Check

This example demonstrates managing health checks and notification for records

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v3.0.0"

  domain_name = "psin-lab.com"

  records = [
    {
      name                             = "www"
      set_identifier                   = "endpoint-check-tcp-demo"
      type                             = "AAAA"
      values                           = ["2001:4860:4860::8888"]
      multivalue_answer_routing_policy = {}

      health_check = {
        endpoint_check = {
          url = "tcp://[2001:4860:4860::8888]:53"
        }

        # Manages multiple cloudwatch alarms
        # The keys of the map will be the alarm names
        cloudwatch_alarms = {
          # Ensuring over 50% of health checkers are healthy
          "www-endpoint-check-tcp-demo-health-check-percent-healthy" = {
            metric_name            = "HealthCheckPercentageHealthy"
            expression             = "Average < 50"
            notification_sns_topic = "route53-healthcheck"
          }

          # Ensure health check status is healthy
          "www-endpoint-check-tcp-demo-health-check-status" = {
            metric_name            = "HealthCheckStatus"
            expression             = "Average < 1"
            notification_sns_topic = "route53-healthcheck"
          }
        }
      }
    },
    {
      name                             = "www"
      set_identifier                   = "endpoint-check-http-demo"
      type                             = "A"
      values                           = ["8.8.8.8"]
      multivalue_answer_routing_policy = {}

      health_check = {
        endpoint_check = {
          url           = "https://www.google.com/search?q=hello"
          search_string = "hello"
        }
      }
    },
    {
      name                             = "www"
      set_identifier                   = "calculated-check-demo"
      type                             = "A"
      values                           = ["8.8.4.4"]
      multivalue_answer_routing_policy = {}

      health_check = {
        calculated_check = {
          health_checks_to_monitor = [
            "28d3d944-8a14-4a64-be65-cf0942ec1b98",
            "40addf19-4d67-41e8-88ae-9936b7f0f409"
          ]
        }
      }
    },
    {
      name                             = "www"
      set_identifier                   = "cloudwatch-alarm-check-demo"
      type                             = "AAAA"
      values                           = ["2001:4860:4860::8844"]
      multivalue_answer_routing_policy = {}

      health_check = {
        cloudwatch_alarm_check = {
          alarm_name = "psin_test_r53_endpoint_check"
        }
      }
    }
  ]
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">domain_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The domain name of the hosted zone

    

    

    

    

    
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

Additional tags for the hosted zone

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources in deployed with this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the hosted zone

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enablednssec">EnableDnssec</a>)</code></td>
    <td width="100%">enable_dnssec</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables [Route 53 DNSSEC][route53-dnssec] signing.

    

    

    
**Examples:**
- [DNSSEC Example](#dnssec)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enablequerylogging">EnableQueryLogging</a>)</code></td>
    <td width="100%">enable_query_logging</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables Route 53 query log

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#primaryprivatezonevpcassociation">PrimaryPrivateZoneVpcAssociation</a>)</code></td>
    <td width="100%">primary_private_zone_vpc_association</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The primary VPC ID this private hosted zone is used to resolve DNS queries for.
Do not specify if you want to create a public hosted zone. Please read the Managing
Cross-Account VPC Associations in the Known Limitation for more information and recommended
usage. This will be removed when AWS updated a fix.

    

    

    
**Examples:**
- [Private Hosted Zone Example](#private-hosted-zone)

    

    
**Since:** 3.0.0
        


</td></tr>
<tr>
    <td><code>map(list(string))</code></td>
    <td width="100%">private_zone_vpc_associations</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

One of more VPC IDs this private hosted zone is used to resolve DNS queries
for. Do not specify if you want to create a public hosted zone.

    

    

    
**Examples:**
- [Private Hosted Zone Example](#private-hosted-zone)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#records">Records</a>))</code></td>
    <td width="100%">records</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

Manages multiple records.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">vpc_association_authorizations</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of VPC IDs from external accounts that you want to authorize to be
associated with this zone. Only applicable to private hosted zone. Please
refer to [this documentation][route53-private-vps-diff-accts] for more
infomation.

    

    

    
**Examples:**
- [Private Hosted Zone Example](#private-hosted-zone)

    

    
**Since:** 2.1.0
        


</td></tr>
</tbody></table>

### Objects



#### Alias

Create an alias record. Mutually exclusive with `values` and `ttl`

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">target</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the endpoint where this alias record routes traffic to.

    

    

    

    
**Links:**
- [Supported services you can create an Alias record for](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-aws-resources.html)

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">hosted_zone_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the hosted zone ID of the target endpoint.

    

    

    

    
**Links:**
- [Supported AWS service endpoints](https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html)

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">evaluate_target_health</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether the alias records evaluate the health of the target endpoint

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### CalculatedCheck

Configures the [calculated health check][route53-health-check-types],
where the health of this health check depends on the status of the other
health checks

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">health_checks_to_monitor</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of health checks that must be healthy for this check to be
considered healthy

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">healthy_threshold</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the number of monitoring health checks that must be healthy
for this check to be considered healthy. If not specified, all health
checks must be healthy for this check to be considered healthy

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### CloudwatchAlarmCheck

Configures the [Cloudwatch Alarm Checks][route53-health-check-types].
The status of this health check is based on the state of a specified
CloudWatch alarm

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">alarm_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the alarm that determines the status of this health check

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">alarm_region</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The Cloudwatch region that contains the alarm that you want Route 53
to use for this health check. If not specified, the current region
will be used.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">insufficient_data_health_status</td>
    <td><code>"LastKnownStatus"</code></td>
</tr>
<tr><td colspan="3">

The status of this health check when Cloudwatch doesn't have enough
data to determine whether the alarm is in the OK or the ALARM state.

    
**Allowed Values:**
- `Healthy`
- `Unhealthy`
- `LastKnownStatus`

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### CloudwatchAlarms

Create [Cloudwatch alarms][route53-health-check-cloudwatch-alarm] to
notify you health check status changes.

    

    

    
**Examples:**
- [Health Check Example](#health-check)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">metric_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The metric to monitor.

    
**Allowed Values:**
- `ChildHealthCheckHealthyCount`
- `HealthCheckPercentageHealthy`
- `HealthCheckStatus`

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

The expression in `<statistic> <operator> <unit>` format. For example: `Average < 50`

- **ChildHealthCheckHealthyCount**: The number of child health checks that are healthy
Statistics: Average (recommended), Minimum, Maximum
Valid For Healthcheck Types: Calculated
- **HealthCheckPercentageHealthy**: The percentage of Route 53 health checkers that consider the selected endpoint to be healthy.
Statistics: Average, Minimum, Maximum
Valid For Healthcheck Types: Endpoint, Cloudwatch Alarm
- **HealthCheckStatus**: The status of the health check endpoint that CloudWatch is checking. 1 indicates healthy, and 0 indicates unhealthy.
Statistics: Average, Minimum, Maximum
Valid For Healthcheck Types: All

    

    
**Regex Pattern:**
```
(Average|Minimum|Maximum) (<=|<|>=|>) (\d+)
```


        

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">evaluation_periods</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

The number of periods over which data is compared to the specified threshold.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">period</td>
    <td><code>60</code></td>
</tr>
<tr><td colspan="3">

The period in seconds over which the specified statistic is applied.

Valid values are 10, 30, and any multiple of 60.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">notification_sns_topic</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The SNS topic where notification will be sent

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### Coordinates

Specify the coordinates where your resources are deployed in.

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">latitude</td>
    <td></td>
</tr>
<tr><td colspan="3">

The latitude of the coordinates

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">longitude</td>
    <td></td>
</tr>
<tr><td colspan="3">

The longitude of the coordinates

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### EnableDnssec



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#keysigningkeys">KeySigningKeys</a>))</code></td>
    <td width="100%">key_signing_keys</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages the KSKs route 53 used to sign records. You can define up to two
KSK for key rotation purposes.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">status</td>
    <td><code>"SIGNING"</code></td>
</tr>
<tr><td colspan="3">

Specify whether to sign the zone with DNSSEC.

    
**Allowed Values:**
- `SIGNING`
- `NOT_SIGNING`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableQueryLogging



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">cloudwatch_log_group_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

An existing Cloudwatch log group to send query logging to

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">create_resource_policy</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Creates a Cloudwatch log resource policy named AWSServiceRoleForRoute53
to grant route 53 permissions to send logs to Cloudwatch. You do not need
to create this if one is already created.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">log_group_class</td>
    <td><code>"STANDARD"</code></td>
</tr>
<tr><td colspan="3">

Specified the log class of the log group. Mutually exclusive with
`cloudwatch_log_group_arn`.

    
**Allowed Values:**
- `STANDARD`
- `INFREQUENT_ACCESS`

    

    

    

    


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retention</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

Specifies the number of days you want to retain log events in the
specified log group.

If you select `0`, the events in the log group are always retained and
never expire. Mutually exclusive with `cloudwatch_log_group_arn`

    
**Allowed Values:**
- `0`
- `1`
- `3`
- `5`
- `7`
- `14`
- `30`
- `60`
- `90`
- `120`
- `150`
- `180`
- `365`
- `400`
- `545`
- `731`
- `1096`
- `1827`
- `2192`
- `2557`
- `2922`
- `3288`
- `3653`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EndpointCheck

Configures the [Endpoint check][route53-health-check-types]. Multiple
Route 53 health checkers will try to establish a TCP connection with
the specified endpoint to determine whether it is healthy.

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">url</td>
    <td></td>
</tr>
<tr><td colspan="3">

The full URL

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_latency_graphs</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether you want Route 53 to display the latency graph on the health
check page in the Route 53 console

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">failure_threshold</td>
    <td><code>3</code></td>
</tr>
<tr><td colspan="3">

The number of consecutive health checks that an endpoint must pass or
fail for Route 53 to change the current status of the endpoint from
healthy to unhealthy or vice versa

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">hostname</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Route 53 passes this value in a HOST header when establishing the
connection.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">regions</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of AWS regions that you want Amazon Route 53 health checkers
to check the specified endpoint from

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">request_interval</td>
    <td><code>30</code></td>
</tr>
<tr><td colspan="3">

The number of seconds between the time that Amazon Route 53 gets a
response from your endpoint and the time that it sends the next
health-check request.

    
**Allowed Values:**
- `10`
- `30`

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">search_string</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The string that you want Route 53 to search for in the body of the
response from the specified endpoint.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### FailoverRoutingPolicy

Configures the [Failover Routing Policy][route53-routing-policy-failover].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Failover Routing Policy Example](#failover-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">failover_record_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the failover routing policy type.

    
**Allowed Values:**
- `PRIMARY`
- `SECONDARY`

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### GeolocationRoutingPolicy

Configures the [Geolocation Routing Policy][route53-routing-policy-geolocation].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Geolocation Routing Policy Example](#geolocation-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the location where your resources are deployed in. Please refer
to [this file](./_common.tf) for a list of supported values.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### GeoproximityRoutingPolicy

Configures the [Geoproximity Routing Policy][route53-routing-policy-geoproximity].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Geoproximity Routing Policy Example](#geoproximity-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">bias</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

Expand or shrink the size of the geographic region from which Route 53
routes traffic to a resource. Valid value is between `-99` to `99`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">local_zone_group</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the AWS local zone where your resources are deployed in. To use
AWS Local Zones, you have to first [enable them][aws-local-zones].

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">region</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the AWS region where your resources are deployed in.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#coordinates">Coordinates</a>)</code></td>
    <td width="100%">coordinates</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the coordinates where your resources are deployed in.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### HealthCheck

Creates a [Route 53 health check][route53-health-check] and attach it to
this record. Only available when a routing policy is specified. Mutually
exclusive with `health_check_id`.

    

    

    
**Examples:**
- [Health Check Example](#health-check)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether this health check is enabled

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">invert_health_check_status</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether you want Route 53 to invert the status of the health check. For
example, to consider a health check as healthy when it is otherwise
would be considered unhealthy

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#calculatedcheck">CalculatedCheck</a>)</code></td>
    <td width="100%">calculated_check</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [calculated health check][route53-health-check-types],
where the health of this health check depends on the status of the other
health checks

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#cloudwatchalarmcheck">CloudwatchAlarmCheck</a>)</code></td>
    <td width="100%">cloudwatch_alarm_check</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Cloudwatch Alarm Checks][route53-health-check-types].
The status of this health check is based on the state of a specified
CloudWatch alarm

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#cloudwatchalarms">CloudwatchAlarms</a>))</code></td>
    <td width="100%">cloudwatch_alarms</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Create [Cloudwatch alarms][route53-health-check-cloudwatch-alarm] to
notify you health check status changes.

    

    

    
**Examples:**
- [Health Check Example](#health-check)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#endpointcheck">EndpointCheck</a>)</code></td>
    <td width="100%">endpoint_check</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Endpoint check][route53-health-check-types]. Multiple
Route 53 health checkers will try to establish a TCP connection with
the specified endpoint to determine whether it is healthy.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### KeySigningKeys

Manages the KSKs route 53 used to sign records. You can define up to two
KSK for key rotation purposes.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an existing customer managed KMS key for KSK. If this is not
specified, a default one will be created. The customer managed KMS key
must meet all requirements described in [this documentation][route53-ksk-kms-requirements].

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">status</td>
    <td><code>"ACTIVE"</code></td>
</tr>
<tr><td colspan="3">

The status of the KSK

    
**Allowed Values:**
- `ACTIVE`
- `INACTIVE`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### LatencyRoutingPolicy

Configures the [Latency-based Routing Policy][route53-routing-policy-latency].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Latency-based Routing Policy Example](#latency-based-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">region</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AWS region where the resource that you specified in this record
resides. You can only create one latency record for each region.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### MultivalueAnswerRoutingPolicy

Configures the [Multivalue Answer Routing Policy][route53-routing-policy-multivalue-answer].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Multivalue Answer Routing Policy Example](#multivalue-answer-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether this routing policy is enabled

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### PrimaryPrivateZoneVpcAssociation



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">vpc_id</td>
    <td></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">region</td>
    <td></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
</tbody></table>



#### Records



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the record

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the record type.

    
**Allowed Values:**
- `A`
- `AAAA`
- `CAA`
- `CNAME`
- `DS`
- `MX`
- `NAPTR`
- `NS`
- `PTR`
- `SOA`
- `SPF`
- `SRV`
- `TXT`

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">values</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A list of values this record routes traffic to. This is required for
non-alias records. Mutually exclusive with `alias`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">health_check_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify an existing health check this reocrd is associated to

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">ttl</td>
    <td><code>300</code></td>
</tr>
<tr><td colspan="3">

Specify the time-to-live (TTL) of the record. This is ignored for alias
records.

Mutually exclusive with `alias`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">set_identifier</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a value that uniquely identifies each record that has the same
name and type. Required with routing policy other than simple (no
routing policy)

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#alias">Alias</a>)</code></td>
    <td width="100%">alias</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Create an alias record. Mutually exclusive with `values` and `ttl`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#failoverroutingpolicy">FailoverRoutingPolicy</a>)</code></td>
    <td width="100%">failover_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Failover Routing Policy][route53-routing-policy-failover].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Failover Routing Policy Example](#failover-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#geolocationroutingpolicy">GeolocationRoutingPolicy</a>)</code></td>
    <td width="100%">geolocation_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Geolocation Routing Policy][route53-routing-policy-geolocation].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Geolocation Routing Policy Example](#geolocation-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#geoproximityroutingpolicy">GeoproximityRoutingPolicy</a>)</code></td>
    <td width="100%">geoproximity_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Geoproximity Routing Policy][route53-routing-policy-geoproximity].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Geoproximity Routing Policy Example](#geoproximity-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#latencyroutingpolicy">LatencyRoutingPolicy</a>)</code></td>
    <td width="100%">latency_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Latency-based Routing Policy][route53-routing-policy-latency].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Latency-based Routing Policy Example](#latency-based-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#multivalueanswerroutingpolicy">MultivalueAnswerRoutingPolicy</a>)</code></td>
    <td width="100%">multivalue_answer_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Multivalue Answer Routing Policy][route53-routing-policy-multivalue-answer].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Multivalue Answer Routing Policy Example](#multivalue-answer-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#weightedroutingpolicy">WeightedRoutingPolicy</a>)</code></td>
    <td width="100%">weighted_routing_policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [Weighted Routing Policy][route53-routing-policy-weighted].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Weighted Routing Policy Example](#weighted-routing-policy)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#healthcheck">HealthCheck</a>)</code></td>
    <td width="100%">health_check</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates a [Route 53 health check][route53-health-check] and attach it to
this record. Only available when a routing policy is specified. Mutually
exclusive with `health_check_id`.

    

    

    
**Examples:**
- [Health Check Example](#health-check)

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### WeightedRoutingPolicy

Configures the [Weighted Routing Policy][route53-routing-policy-weighted].
You may only define one routing policy for a single record.

    

    

    
**Examples:**
- [Weighted Routing Policy Example](#weighted-routing-policy)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td></td>
</tr>
<tr><td colspan="3">

The weight that determines the proportion of DNS queries that Route 53
will respond to.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>




[aws-local-zones]: https://docs.aws.amazon.com/local-zones/latest/ug/getting-started.html

[route53-dnssec]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-configure-dnssec.html

[route53-health-check]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html

[route53-health-check-cloudwatch-alarm]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-monitor-view-status.html

[route53-health-check-types]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html

[route53-ksk-kms-requirements]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html

[route53-private-vps-diff-accts]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs-different-accounts.html

[route53-routing-policy-failover]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-failover.html

[route53-routing-policy-geolocation]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html

[route53-routing-policy-geoproximity]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html

[route53-routing-policy-latency]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-latency.html

[route53-routing-policy-multivalue-answer]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html

[route53-routing-policy-weighted]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-weighted.html


<!-- TFDOCS_EXTRAS_END -->

## Outputs

- (string) **`route53_hosted_zone_arn`** _[since v1.0.0]_

    The ARN of the Route 53 hosted zone

- (string) **`route53_hosted_zone_id`** _[since v1.0.0]_

    The ID of the Route 53 hosted zone

- (list(string)) **`route53_hosted_zone_name_servers`** _[since v1.0.0]_

    A list of name servers in associated (or default) delegation set

- (string) **`route53_hosted_zone_primary_name_server`** _[since v1.1.0]_

    The Route 53 name server that created the SOA record

## Known Limitations

### Managing Cross-Account VPC Associations

Terraform provides both exclusive VPC associations defined in-line in the `aws_route53_zone` resource via the `vpc` configuration blocks and a separate `aws_route53_zone_association` resource. At this time, you cannot use in-line VPC associations in conjunction with any `aws_route53_zone_association` resources with the same zone ID otherwise Terraform will attempt to destroy any VPC associations declared outside of the `aws_route53_zone.vpc` configuration blocks in future applies. This problem surfaces when one must setup cross-account zone associations. However, in order to create a private hosted zone, at least one VPC association must be declared in the `aws_route53_zone.vpc` configuration block. As a workaround to this problem, v3.0.0 introduces a new variable `primary_private_zone_vpc_association` for the first association using the `aws_route53_zone.vpc` configuration block so that the private hosted zone can be created properly, afterward, any changes to the `aws_route53_zone.vpc` configuration block will be ignored, and any additional VPC associations should be declared with the `private_zone_vpc_associations` variable. Since the association declared with the `primary_private_zone_vpc_association` variable will be ignored, **WE RECOMMEND CREATING A DUMMY VPC FOR THIS FIRST ASSOCIATION**

[aws-local-zones]:https://docs.aws.amazon.com/local-zones/latest/ug/getting-started.html
[aws-service-endpoints]:https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html
[route53-alias-record]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
[route53-dnssec]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-configure-dnssec.html
[route53-dnssec-chain-of-trust]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-enable-signing.html#dns-configuring-dnssec-chain-of-trust
[route53-health-check]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
[route53-health-check-cloudwatch-alarm]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-monitor-view-status.html
[route53-health-check-types]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html
[route53-hosted-zone-private-associate-vpcs-different-accounts]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs-different-accounts.html
[route53-ksk]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-ksk.html
[route53-ksk-kms-requirements]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html
[route53-query-logging]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/query-logs.html
[route53-routing-policy-failover]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-failover.html
[route53-routing-policy-geolocation]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html
[route53-routing-policy-geoproximity]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html
[route53-routing-policy-latency]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-latency.html
[route53-routing-policy-multivalue-answer]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html
[route53-routing-policy-weighted]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-weighted.html
