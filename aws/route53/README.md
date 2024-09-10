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
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

This example creates a hosted zone psin-lab.com and several records

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

  domain_name = "psin-lab.local"

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
}
```

### DNSSEC

This example demonstrates how to enable DNSSEC signing by using a default KSK. After enabling DNSSEC signing, you must follow this [instructions here][route53-dnssec-chain-of-trust] to create the DS record in the parent zone.

```terraform
module "psin_lab_com" {
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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
  source = "github.com/FriendsOfTerraform/aws-route53.git?ref=v2.0.0"

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

## Argument Reference

### Mandatory

- (string) **`domain_name`** _[since v1.0.0]_

    The domain name of the hosted zone

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the hosted zone

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (string) **`description = null`** _[since v1.0.0]_

    The description of the hosted zone

- (object) **`enable_dnssec = null`** _[since v1.0.0]_

    Enables [Route 53 DNSSEC][route53-dnssec] signing. Please [see example](#dnssec).

    - (map(object)) **`key_signing_keys`** _[since v1.0.0]_

        Manages the KSKs route 53 used to sign records. You can define up to two KSK for key rotation purposes.

        - (string) **`kms_key_id = null`** _[since v1.0.0]_

            Specify an existing customer managed KMS key for KSK. If this is not specified, a default one will be created. The customer managed KMS key must meet all requirements described in [this documentation][route53-ksk-kms-requirements].

        - (string) **`status = "ACTIVE"`** _[since v1.0.0]_

            The status of the KSK. Valid values: `"ACTIVE"`, `"INACTIVE"`

    - (string) **`status = "SIGNING"`** _[since v1.0.0]_

        Specify whether to sign the zone with DNSSEC. Valid values: `"SIGNING"`, `"NOT_SIGNING"`

- (object) **`enable_query_logging = null`** _[since v1.0.0]_

    Enables [Route 53 Query Logging][route53-query-logging].

    - (string) **`cloudwatch_log_group_arn = null`** _[since v1.0.0]_

        An existing Cloudwatch log group to send query logging to

    - (bool) **`create_resource_policy = false`** _[since v1.0.0]_

        Creates a Cloudwatch log resource policy named AWSServiceRoleForRoute53 to grant route 53 permissions to send logs to Cloudwatch. You do not need to create this if one is already created

    - (string) **`log_group_class = "STANDARD"`** _[since v1.0.0]_

        Specified the log class of the log group. Possible values are: `"STANDARD"`, `"INFREQUENT_ACCESS"`. Mutually exclusive with `cloudwatch_log_group_arn`

    - (number) **`retention = 0`** _[since v1.0.0]_

        Specifies the number of days you want to retain log events in the specified log group. Possible values are: `1`, `3`, `5`, `7`, `14`, `30`, `60`, `90`, `120`, `150`, `180`, `365`, `400`, `545`, `731`, `1096`, `1827`, `2192`, `2557`, `2922`, `3288`, `3653`,`0`. If you select `0`, the events in the log group are always retained and never expire. Mutually exclusive with `cloudwatch_log_group_arn`

- (map(list(string))) **`private_zone_vpc_associations = {}`** _[since v1.0.0]_

    One of more VPC IDs this private hosted zone is used to resolve DNS queries for. Do not specify if you want to create a public hosted zone. Please [see example](#private-hosted-zone)

- (list(object)) **`records = []`** _[since v2.0.0]_

    Manages multiple records. Please [see example](#basic-usage).

    - (string) **`name`** _[since v2.0.0]_

        The name of the record

    - (string) **`type`** _[since v2.0.0]_

        Specify the record type. Valid values are: `"A"`, `"AAAA"`, `"CAA"`, `"CNAME"`, `"DS"`, `"MX"`, `"NAPTR"`, `"NS"`, `"PTR"`, `"SOA"`, `"SPF"`, `"SRV"`, `"TXT"`

    - (string) **`set_identifier = null`** _[since v2.0.0]_

        Specify a value that uniquely identifies each record that has the same name and type. Required with routing policy other than simple (no routing policy)

    - (list(string)) **`values = null`** _[since v2.0.0]_

        A list of values this record routes traffic to. This is required for non-alias records. Mutually exclusive with `alias`

    - (string) **`health_check_id = null`** _[since v2.0.0]_

        Specify an existing health check this reocrd is associated to

    - (number) **`ttl = 300`** _[since v2.0.0]_

        Specify the time-to-live(TTL) of the record. This is ignored for alias records. Mutually exclusive with `alias`

    - (object) **`alias = null`** _[since v2.0.0]_

        Create an alias record. Mutually exclusive with `values` and `ttl`

        - (string) **`target`** _[since v2.0.0]_

            Specify the endpoint where this alias record routes traffic to. Please refer to [this documentation][route53-alias-record] for a list of supported services that you can create Alias record for.

        - (string) **`hosted_zone_id`** _[since v2.0.0]_

            Specify the hosted zone ID of the target endpoint. You can find the value for each supported endpoints in [this documentation][aws-service-endpoints].

        - (bool) **`evaluate_target_health = true`** _[since v2.0.0]_

            Whether the alias records evaluate the health of the target endpoint

    - (object) **`failover_routing_policy = null`** _[since v2.0.0]_

        Configures the [Failover Routing Policy][route53-routing-policy-failover]. You may only define one routing policy for a single record. Please [see example](#failover-routing-policy)

        - (string) **`failover_routing_policy_type`** _[since v2.0.0]_

            Specify the failover routing policy type. Valid values: `"PRIMARY"`, `"SECONDARY"`

    - (object) **`geolocation_routing_policy = null`** _[since v2.0.0]_

        Configures the [Geolocation Routing Policy][route53-routing-policy-geolocation]. You may only define one routing policy for a single record. Please [see example](#geolocation-routing-policy)

        - (string) **`location`** _[since v2.0.0]_

            Specify the location where your resources are deployed in. Please refer to [this file](./_common.tf) for a list of supported values.

    - (object) **`geoproximity_routing_policy = null`** _[since v2.0.0]_

        Configures the [Geoproximity Routing Policy][route53-routing-policy-geoproximity]. You may only define one routing policy for a single record. Please [see example](#geoproximity-routing-policy)

        - (number) **`bias = 0`** _[since v2.0.0]_

            Expand or shrink the size of the geographic region from which Route 53 routes traffic to a resource. Refer to [this documentation][route53-routing-policy-geoproximity] for more information. Valid value is between `-99` to `99`

        - (string) **`local_zone_group = null`** _[since v2.0.0]_

            Specify the AWS local zone where your resources are deployed in. To use AWS Local Zones, you have to first [enable them][aws-local-zones].

        - (string) **`region = null`** _[since v2.0.0]_

            Specify the AWS region where your resources are deployed in.

        - (object) **`coordinates = null`** _[since v2.0.0]_

            Specify the coordinates where your resources are deployed in.

            - (string) **`latitude`** _[since v2.0.0]_

                The latitude of the coordinates

            - (string) **`longitude`** _[since v2.0.0]_

                The longitude of the coordinates

    - (object) **`latency_routing_policy = null`** _[since v2.0.0]_

        Configures the [Latency-based Routing Policy][route53-routing-policy-latency]. You may only define one routing policy for a single record. Please [see example](#latency-based-routing-policy)

        - (string) **`region`** _[since v2.0.0]_

            The AWS region where the resource that you specified in this record resides. You can only create one latency record for each region.

    - (object) **`multivalue_answer_routing_policy = null`** _[since v2.0.0]_

        Configures the [Multivalue Answer Routing Policy][route53-routing-policy-multivalue-answer]. You may only define one routing policy for a single record. Please [see example](#multivalue-answer-routing-policy)

        - (bool) **`enabled = true`** _[since v2.0.0]_

            Whether this routing policy is enabled

    - (object) **`weighted_routing_policy = null`** _[since v2.0.0]_

        Configures the [Weighted Routing Policy][route53-routing-policy-weighted]. You may only define one routing policy for a single record. Please [see example](#weighted-routing-policy)

        - (number) **`weight`** _[since v2.0.0]_

            The weight that determines the proportion of DNS queries that Route 53 will respond to.

    - (object) **`health_check = null`** _[since v2.0.0]_

        Creates a [Route 53 health check][route53-health-check] and attach it to this record. Only available when a routing policy is specified. Mutually exclusive with `health_check_id`. Please [see example](#health-check)

        - (bool) **`enabled = true`** _[since v2.0.0]_

            Whether this health check is enabled

        - (bool) **`invert_health_check_status = false`** _[since v2.0.0]_

            Whether you want Route 53 to invert the status of the health check. For example, to consider a health check as healthy when it is otherwise would be considered unhealthy

        - (object) **`calculated_check = null`** _[since v2.0.0]_

            Configures the [calculated health check][route53-health-check-types], where the health of this health check depends on the status of the other health checks

            - (list(string)) **`health_checks_to_monitor`** _[since v2.0.0]_

                List of health checks that must be healthy for this check to be considered healthy

            - (number) **`healthy_threshold = null`** _[since v2.0.0]_

                Specify the number of monitoring health checks that must be healthy for this check to be considered healthy. If not specified, all health checks must be healthy for this check to be considered healthy

        - (object) **`cloudwatch_alarm_check = null`** _[since v2.0.0]_

            Configures the [Cloudwatch Alarm Checks][route53-health-check-types]. The status of this health check is based on the state of a specified CloudWatch alarm

            - (string) **`alarm_name`** _[since v2.0.0]_

                The name of the alarm that determines the status of this health check

            - (string) **`alarm_region = null`** _[since v2.0.0]_

                The Cloudwatch region that contains the alarm that you want Route 53 to use for this health check. If not specified, the current region will be used.

            - (string) **`insufficient_data_health_status = "LastKnownStatus"`** _[since v2.0.0]_

                The status of this health check when Cloudwatch doesn't have enough data to determine whether the alarm is in the OK or the ALARM state. Valid values: `"Healthy"`, `"Unhealthy"`, `"LastKnownStatus"`

        - (map(object)) **`cloudwatch_alarms = null`** _[since v2.0.0]_

            Create [Cloudwatch alarms][route53-health-check-cloudwatch-alarm] to notify you health check status changes. Please [see example](#health-check)

            - (string) **`metric_name`** _[since v2.0.0]_

                The metric to monitor. Valid values:
                | Metric Name                  | Description                                                                                                          | Statistics                              | Valid For Healthcheck Types
                |------------------------------|----------------------------------------------------------------------------------------------------------------------|-----------------------------------------|----------------------------------
                | ChildHealthCheckHealthyCount | The number of health checks that are healthy.                                                                        | Average (recommended), Minimum, Maximum | Calculated
                | HealthCheckPercentageHealthy | The percentage of Route 53 health checkers that consider the selected endpoint to be healthy.                        | Average, Minimum, Maximum               | Endpoint, Cloudwatch Alarm
                | HealthCheckStatus            | The status of the health check endpoint that CloudWatch is checking. 1 indicates healthy, and 0 indicates unhealthy. | Average, Minimum, Maximum               | All

            - (string) **`expression`** _[since v2.0.0]_

                The expression in `<statistic> <operator> <unit>` format. For example: `Average < 50`

            - (number) **`evaluation_periods = 1`** _[since v2.0.0]_

                The number of periods over which data is compared to the specified threshold.

            - (number) **`period = 60`** _[since v2.0.0]_

                The period in seconds over which the specified statistic is applied. Valid values are `10`, `30`, or `any multiple of 60`

            - (string) **`notification_sns_topic = null`** _[since v2.0.0]_

                The SNS topic where notification will be sent

        - (object) **`endpoint_check = null`** _[since v2.0.0]_

            Configures the [Endpoint check][route53-health-check-types]. Multiple Route 53 health checkers will try to establish a TCP connection with the specified endpoint to determine whether it is healthy.

            - (string) **`url`** _[since v2.0.0]_

                The full URL

            - (bool) **`enable_latency_graphs = false`** _[since v2.0.0]_

                Whether you want Route 53 to display the latency graph on the health check page in the Route 53 console

            - (number) **`failure_threshold = 3`** _[since v2.0.0]_

                The number of consecutive health checks that an endpoint must pass or fail for Route 53 to change the current status of the endpoint from healthy to unhealthy or vice versa

            - (string) **`hostname = null`** _[since v2.0.0]_

                Route 53 passes this value in a HOST header when establishing the connection.

            - (list(string)) **`regions = null`** _[since v2.0.0]_

                A list of AWS regions that you want Amazon Route 53 health checkers to check the specified endpoint from

            - (number) **`request_interval = 30`** _[since v2.0.0]_

                The number of seconds between the time that Amazon Route 53 gets a response from your endpoint and the time that it sends the next health-check request. Valid values: `10`, `30`

            - (string) **`search_string = null`** _[since v2.0.0]_

                The string that you want Route 53 to searh for in the body of the response from the specified endpoint

## Outputs

- (string) **`route53_hosted_zone_arn`** _[since v1.0.0]_

    The ARN of the Route 53 hosted zone

- (string) **`route53_hosted_zone_id`** _[since v1.0.0]_

    The ID of the Route 53 hosted zone

- (list(string)) **`route53_hosted_zone_name_servers`** _[since v1.0.0]_

    A list of name servers in associated (or default) delegation set

- (string) **`route53_hosted_zone_primary_name_server`** _[since v1.1.0]_

    The Route 53 name server that created the SOA record

[aws-local-zones]:https://docs.aws.amazon.com/local-zones/latest/ug/getting-started.html
[aws-service-endpoints]:https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html
[route53-alias-record]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
[route53-dnssec]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-configure-dnssec.html
[route53-dnssec-chain-of-trust]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-enable-signing.html#dns-configuring-dnssec-chain-of-trust
[route53-health-check]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
[route53-health-check-cloudwatch-alarm]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-monitor-view-status.html
[route53-health-check-types]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html
[route53-ksk]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-ksk.html
[route53-ksk-kms-requirements]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html
[route53-query-logging]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/query-logs.html
[route53-routing-policy-failover]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-failover.html
[route53-routing-policy-geolocation]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html
[route53-routing-policy-geoproximity]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html
[route53-routing-policy-latency]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-latency.html
[route53-routing-policy-multivalue-answer]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html
[route53-routing-policy-weighted]:https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-weighted.html
