variable "domain_name" {
  type        = string
  description = <<EOT
    The domain name of the hosted zone

    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = <<EOT
    Additional tags for the hosted zone

    @since 1.0.0
  EOT
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources in deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "description" {
  type        = string
  description = <<EOT
    The description of the hosted zone

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_dnssec" {
  type = object({
    /// Manages the KSKs route 53 used to sign records. You can define up to two
    /// KSK for key rotation purposes.
    ///
    /// @since 1.0.0
    key_signing_keys = map(object({
      /// Specify an existing customer managed KMS key for KSK. If this is not
      /// specified, a default one will be created. The customer managed KMS key
      /// must meet all requirements described in [this documentation][route53-ksk-kms-requirements].
      ///
      /// @link {route53-ksk-kms-requirements} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html
      /// @since 1.0.0
      kms_key_id = optional(string, null)

      /// The status of the KSK
      ///
      /// @enum ACTIVE|INACTIVE
      /// @since 1.0.0
      status = optional(string, "ACTIVE")
    }))

    /// Specify whether to sign the zone with DNSSEC.
    ///
    /// @enum SIGNING|NOT_SIGNING
    /// @since 1.0.0
    status = optional(string, "SIGNING")
  })
  description = <<EOT
    Enables [Route 53 DNSSEC][route53-dnssec] signing.

    @example "DNSSEC Example" #dnssec
    @link {route53-dnssec} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-configure-dnssec.html
    @since 1.0.0
  EOT
  default     = null
}

variable "enable_query_logging" {
  type = object({
    /// An existing Cloudwatch log group to send query logging to
    ///
    /// @since 1.0.0
    cloudwatch_log_group_arn = optional(string, null)

    /// Creates a Cloudwatch log resource policy named AWSServiceRoleForRoute53
    /// to grant route 53 permissions to send logs to Cloudwatch. You do not need
    /// to create this if one is already created.
    ///
    /// @since 1.0.0
    create_resource_policy = optional(bool, false)

    /// Specified the log class of the log group. Mutually exclusive with
    /// `cloudwatch_log_group_arn`.
    ///
    /// @enum STANDARD|INFREQUENT_ACCESS
    log_group_class = optional(string, "STANDARD")

    /// Specifies the number of days you want to retain log events in the
    /// specified log group.
    ///
    /// If you select `0`, the events in the log group are always retained and
    /// never expire. Mutually exclusive with `cloudwatch_log_group_arn`
    ///
    /// @enum 0|1|3|5|7|14|30|60|90|120|150|180|365|400|545|731|1096|1827|2192|2557|2922|3288|3653
    /// @since 1.0.0
    retention = optional(number, 0)
  })
  description = <<EOT
    Enables Route 53 query log

    @since 1.0.0
  EOT
  default     = null
}

variable "private_zone_vpc_associations" {
  type        = map(list(string))
  description = <<EOT
    One of more VPC IDs this private hosted zone is used to resolve DNS queries
    for. Do not specify if you want to create a public hosted zone.

    @example "Private Hosted Zone Example" #private-hosted-zone
    @since 1.0.0
  EOT
  default     = {}
}

variable "records" {
  type = list(object({
    /// The name of the record
    ///
    /// @since 2.0.0
    name = string

    /// Specify the record type.
    ///
    /// @enum A|AAAA|CAA|CNAME|DS|MX|NAPTR|NS|PTR|SOA|SPF|SRV|TXT
    /// @since 2.0.0
    type = string

    /// A list of values this record routes traffic to. This is required for
    /// non-alias records. Mutually exclusive with `alias`
    ///
    /// @since 2.0.0
    values = optional(list(string), null)

    /// Specify an existing health check this reocrd is associated to
    ///
    /// @since 2.0.0
    health_check_id = optional(string, null)

    /// Specify the time-to-live (TTL) of the record. This is ignored for alias
    /// records.
    ///
    /// Mutually exclusive with `alias`
    ///
    /// @since 2.0.0
    ttl = optional(number, 300)

    /// Specify a value that uniquely identifies each record that has the same
    /// name and type. Required with routing policy other than simple (no
    /// routing policy)
    ///
    /// @since 2.0.0
    set_identifier = optional(string, null)

    /// Create an alias record. Mutually exclusive with `values` and `ttl`
    ///
    /// @since 2.0.0
    alias = optional(object({
      /// Specify the endpoint where this alias record routes traffic to.
      ///
      /// @link "Supported services you can create an Alias record for" https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-aws-resources.html
      /// @since 2.0.0
      target = string

      /// Specify the hosted zone ID of the target endpoint.
      ///
      /// @link "Supported AWS service endpoints" https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html
      /// @since 2.0.0
      hosted_zone_id = string

      /// Whether the alias records evaluate the health of the target endpoint
      ///
      /// @since 2.0.0
      evaluate_target_health = optional(bool, true)
    }), null)

    /// Configures the [Failover Routing Policy][route53-routing-policy-failover].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Failover Routing Policy Example" #failover-routing-policy
    /// @link {route53-routing-policy-failover} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-failover.html
    /// @since 2.0.0
    failover_routing_policy = optional(object({
      /// Specify the failover routing policy type.
      ///
      /// @enum PRIMARY|SECONDARY
      /// @since 2.0.0
      failover_record_type = string
    }), null)

    /// Configures the [Geolocation Routing Policy][route53-routing-policy-geolocation].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Geolocation Routing Policy Example" #geolocation-routing-policy
    /// @link {route53-routing-policy-geolocation} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html
    /// @since 2.0.0
    geolocation_routing_policy = optional(object({
      /// Specify the location where your resources are deployed in. Please refer
      /// to [this file](./_common.tf) for a list of supported values.
      ///
      /// @since 2.0.0
      location = string
    }), null)

    /// Configures the [Geoproximity Routing Policy][route53-routing-policy-geoproximity].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Geoproximity Routing Policy Example" #geoproximity-routing-policy
    /// @link {route53-routing-policy-geoproximity} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html
    /// @since 2.0.0
    geoproximity_routing_policy = optional(object({
      /// Expand or shrink the size of the geographic region from which Route 53
      /// routes traffic to a resource. Valid value is between `-99` to `99`
      ///
      /// @since 2.0.0
      bias = optional(number, 0)

      /// Specify the AWS local zone where your resources are deployed in. To use
      /// AWS Local Zones, you have to first [enable them][aws-local-zones].
      ///
      /// @link {aws-local-zones} https://docs.aws.amazon.com/local-zones/latest/ug/getting-started.html
      /// @since 2.0.0
      local_zone_group = optional(string, null)

      /// Specify the AWS region where your resources are deployed in.
      ///
      /// @since 2.0.0
      region = optional(string, null)

      /// Specify the coordinates where your resources are deployed in.
      ///
      /// @since 2.0.0
      coordinates = optional(object({
        /// The latitude of the coordinates
        ///
        /// @since 2.0.0
        latitude = string

        /// The longitude of the coordinates
        ///
        /// @since 2.0.0
        longitude = string
      }), null)
    }), null)

    /// Configures the [Latency-based Routing Policy][route53-routing-policy-latency].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Latency-based Routing Policy Example" #latency-based-routing-policy
    /// @link {route53-routing-policy-latency} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-latency.html
    /// @since 2.0.0
    latency_routing_policy = optional(object({
      /// The AWS region where the resource that you specified in this record
      /// resides. You can only create one latency record for each region.
      ///
      /// @since 2.0.0
      region = string
    }), null)

    /// Configures the [Multivalue Answer Routing Policy][route53-routing-policy-multivalue-answer].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Multivalue Answer Routing Policy Example" #multivalue-answer-routing-policy
    /// @link {route53-routing-policy-multivalue-answer} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html
    /// @since 2.0.0
    multivalue_answer_routing_policy = optional(object({
      /// Whether this routing policy is enabled
      ///
      /// @since 2.0.0
      enabled = optional(bool, true)
    }), null)

    /// Configures the [Weighted Routing Policy][route53-routing-policy-weighted].
    /// You may only define one routing policy for a single record.
    ///
    /// @example "Weighted Routing Policy Example" #weighted-routing-policy
    /// @link {route53-routing-policy-weighted} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-weighted.html
    /// @since 2.0.0
    weighted_routing_policy = optional(object({
      /// The weight that determines the proportion of DNS queries that Route 53
      /// will respond to.
      ///
      /// @since 2.0.0
      weight = number
    }), null)

    /// Creates a [Route 53 health check][route53-health-check] and attach it to
    /// this record. Only available when a routing policy is specified. Mutually
    /// exclusive with `health_check_id`.
    ///
    /// @example "Health Check Example" #health-check
    /// @link {route53-health-check} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
    /// @since 2.0.0
    health_check = optional(object({
      /// Whether this health check is enabled
      ///
      /// @since 2.0.0
      enabled = optional(bool, true)

      /// Whether you want Route 53 to invert the status of the health check. For
      /// example, to consider a health check as healthy when it is otherwise
      /// would be considered unhealthy
      ///
      /// @since 2.0.0
      invert_health_check_status = optional(bool, false)

      /// Configures the [calculated health check][route53-health-check-types],
      /// where the health of this health check depends on the status of the other
      /// health checks
      ///
      /// @link {route53-health-check-types} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html
      /// @since 2.0.0
      calculated_check = optional(object({
        /// List of health checks that must be healthy for this check to be
        /// considered healthy
        ///
        /// @since 2.0.0
        health_checks_to_monitor = list(string)

        /// Specify the number of monitoring health checks that must be healthy
        /// for this check to be considered healthy. If not specified, all health
        /// checks must be healthy for this check to be considered healthy
        ///
        /// @since 2.0.0
        healthy_threshold = optional(number, null)
      }), null)

      /// Configures the [Cloudwatch Alarm Checks][route53-health-check-types].
      /// The status of this health check is based on the state of a specified
      /// CloudWatch alarm
      ///
      /// @link {route53-health-check-types} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html
      /// @since 2.0.0
      cloudwatch_alarm_check = optional(object({
        /// The name of the alarm that determines the status of this health check
        ///
        /// @since 2.0.0
        alarm_name = string

        /// The Cloudwatch region that contains the alarm that you want Route 53
        /// to use for this health check. If not specified, the current region
        /// will be used.
        ///
        /// @since 2.0.0
        alarm_region = optional(string, null)

        /// The status of this health check when Cloudwatch doesn't have enough
        /// data to determine whether the alarm is in the OK or the ALARM state.
        ///
        /// @enum Healthy|Unhealthy|LastKnownStatus
        /// @since 2.0.0
        insufficient_data_health_status = optional(string, "LastKnownStatus")
      }), null)

      /// Create [Cloudwatch alarms][route53-health-check-cloudwatch-alarm] to
      /// notify you health check status changes.
      ///
      /// @example "Health Check Example" #health-check
      /// @link {route53-health-check-cloudwatch-alarm} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-monitor-view-status.html
      /// @since 2.0.0
      cloudwatch_alarms = optional(map(object({
        /// The metric to monitor.
        ///
        /// @enum ChildHealthCheckHealthyCount|HealthCheckPercentageHealthy|HealthCheckStatus
        /// @since 2.0.0
        metric_name = string

        /// The expression in `<statistic> <operator> <unit>` format. For example: `Average < 50`
        ///
        /// - **ChildHealthCheckHealthyCount**: The number of child health checks that are healthy
        ///   Statistics: Average (recommended), Minimum, Maximum
        ///   Valid For Healthcheck Types: Calculated
        /// - **HealthCheckPercentageHealthy**: The percentage of Route 53 health checkers that consider the selected endpoint to be healthy.
        ///   Statistics: Average, Minimum, Maximum
        ///   Valid For Healthcheck Types: Endpoint, Cloudwatch Alarm
        /// - **HealthCheckStatus**: The status of the health check endpoint that CloudWatch is checking. 1 indicates healthy, and 0 indicates unhealthy.
        ///   Statistics: Average, Minimum, Maximum
        ///   Valid For Healthcheck Types: All
        ///
        /// @since 2.0.0
        /// @regex /(Average|Minimum|Maximum) (<=|<|>=|>) (\d+)/
        expression = string # statistic comparison_operator threshold

        /// The number of periods over which data is compared to the specified threshold.
        ///
        /// @since 2.0.0
        evaluation_periods = optional(number, 1)

        /// The period in seconds over which the specified statistic is applied.
        ///
        /// Valid values are 10, 30, and any multiple of 60.
        ///
        /// @since 2.0.0
        period = optional(number, 60)

        /// The SNS topic where notification will be sent
        ///
        /// @since 2.0.0
        notification_sns_topic = optional(string, null)
      })), {})

      /// Configures the [Endpoint check][route53-health-check-types]. Multiple
      /// Route 53 health checkers will try to establish a TCP connection with
      /// the specified endpoint to determine whether it is healthy.
      ///
      /// @link {route53-health-check-types} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html
      /// @since 2.0.0
      endpoint_check = optional(object({
        /// The full URL
        ///
        /// @since 2.0.0
        url = string

        /// Whether you want Route 53 to display the latency graph on the health
        /// check page in the Route 53 console
        ///
        /// @since 2.0.0
        enable_latency_graphs = optional(bool, false)

        /// The number of consecutive health checks that an endpoint must pass or
        /// fail for Route 53 to change the current status of the endpoint from
        /// healthy to unhealthy or vice versa
        ///
        /// @since 2.0.0
        failure_threshold = optional(number, 3)

        /// Route 53 passes this value in a HOST header when establishing the
        /// connection.
        ///
        /// @since 2.0.0
        hostname = optional(string, null)

        /// A list of AWS regions that you want Amazon Route 53 health checkers
        /// to check the specified endpoint from
        ///
        /// @since 2.0.0
        regions = optional(list(string), null)

        /// The number of seconds between the time that Amazon Route 53 gets a
        /// response from your endpoint and the time that it sends the next
        /// health-check request.
        ///
        /// @enum 10|30
        /// @since 2.0.0
        request_interval = optional(number, 30)

        /// The string that you want Route 53 to search for in the body of the
        /// response from the specified endpoint.
        ///
        /// @since 2.0.0
        search_string = optional(string, null)
      }), null)
    }), null)
  }))
  description = <<EOT
    Manages multiple records.

    @example "Basic Usage" #basic-usage
    @since 2.0.0
  EOT
  default     = []
}

variable "vpc_association_authorizations" {
  type        = list(string)
  description = <<EOT
    List of VPC IDs from external accounts that you want to authorize to be
    associated with this zone. Only applicable to private hosted zone. Please
    refer to [this documentation][route53-private-vps-diff-accts] for more
    infomation.

    @example "Private Hosted Zone Example" #private-hosted-zone
    @link {route53-private-vps-diff-accts} https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs-different-accounts.html
    @since 2.1.0
  EOT
  default     = []
}
