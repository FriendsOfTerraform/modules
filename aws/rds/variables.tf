############
## Mandatory
############

variable "authentication_config" {
  type = object({
    /// Manages the DB master account
    ///
    /// @since 1.0.0
    db_master_account = object({
      /// Username for the master DB user
      ///
      /// @since 1.0.0
      username                           = string
      /// Specify the KMS key to encrypt the master password in secrets manager. If not specified, the default KMS key for your AWS account is used. Used when `manage_password_in_secrets_manager = true`
      ///
      /// @since 1.0.0
      customer_kms_key_id                = optional(string)
      /// Set to true to allow RDS to [manage the master user password in Secrets Manager][manage-password-in-secrets-manager]. Mutually exclusive with `password`. This feature does not support Aurora global cluster.
      ///
      /// @link {manage-password-in-secrets-manager} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html
      /// @since 1.0.0
      manage_password_in_secrets_manager = optional(bool)
      /// Password for the master DB user. Mutually exclusive with `manage_password_in_secrets_manager`
      ///
      /// @since 1.0.0
      password                           = optional(string)
    })

    /// Configures [AWS Identity and Access Management (IAM) accounts to database accounts][rds-iam-db-authentication]. Cannot be used when `deployment_option = "MultiAZCluster"`. Refer to the following documentations for instruction to each DB engine.
    ///
    /// - [MySQL, MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html)
    /// - [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html)
    ///
    /// @link {rds-iam-db-authentication} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html
    /// @since 1.0.0
    iam_database_authentication = optional(object({
      /// Specify whether IAM DB authentication is enabled.
      ///
      /// @example "Aurora Regional Cluster" #aurora-regional-cluster
      /// @since 1.0.0
      enabled                          = optional(bool, true)
      /// Specify a list of DB user names to create IAM policies for RDS IAM Authentication. This will allow an IAM principal such as an IAM role to request authentication token for the specific DB user. Please refer to [this documentation][rds-iam-authentication-policy] for more information.
      ///
      /// @link {rds-iam-authentication-policy} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
      /// @since 1.0.0
      create_iam_policies_for_db_users = optional(list(string), [])
    }))
  })
  description = <<EOT
    Configures RDS authentication methods

    @since 1.0.0
  EOT
}

variable "engine" {
  type = object({
    /// Specify the engine type
    ///
    /// @enum aurora-mysql|aurora-postgresql|mysql|postgres|mariadb
    /// @since 1.0.0
    type    = string
    /// Specify the engine version. You can get a list of engine version with `aws rds describe-db-engine-versions --engine aurora-mysql --query DBEngineVersions[].[EngineVersion]`
    ///
    /// @since 1.0.0
    version = string
  })
  description = <<EOT
    Configures RDS engine options

    @since 1.0.0
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    Specify the name of the RDS instance or the RDS cluster

    @since 1.0.0
  EOT
}

variable "networking_config" {
  type = object({
    /// Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. A DB subnet group with at least three AZs must be specified if `deployment_option = "MultiAZCluster"`
    ///
    /// @since 1.0.0
    db_subnet_group_name = string
    /// List of VPC security groups to associate to the RDS instance or cluster
    ///
    /// @since 1.0.0
    security_group_ids   = list(string)
    /// The availability zone to deploy the RDS instance in
    ///
    /// @since 1.0.0
    availability_zone    = optional(string)
    /// The certificate authority (CA) is the certificate that identifies the root CA at the top of the certificate chain. The CA signs the DB server certificate, which is installed on each DB instance. The DB server certificate identifies the DB instance as a trusted server. Please refer to [this documentation][rds-ca] for valid values. Defaults to `"rds-ca-2019"`. Refers to the following documentations for requirements to connect to each DB engine with SSL.
    ///
    /// - [MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mariadb.html)
    /// - [MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mysql.html)
    /// - [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html)
    ///
    /// @link {rds-ca} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.RegionCertificateAuthorities
    /// @since 1.0.0
    ca_cert_identifier   = optional(string)
    /// Specify whether the RDS instance or cluster supports IPv6
    ///
    /// @since 1.0.0
    enable_ipv6          = optional(bool, false)
    /// Specify whether the RDS instance or cluster is publicly accessible
    ///
    /// @since 1.0.0
    enable_public_access = optional(bool, false)
    /// Specify the port on which the DB accepts connections.
    ///
    /// @since 1.0.0
    port                 = optional(number)
  })
  description = <<EOT
    Configures RDS connectivity options

    @since 1.0.0
  EOT
}

############
## Optional
############

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the RDS instance or cluster

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "apply_immediately" {
  type        = bool
  description = <<EOT
    Specifies whether any database modifications are applied immediately, or during the next maintenance window. Using `apply_immediately` can result in a brief downtime as the server reboots.

    @since 1.0.0
  EOT
  default     = null
}

variable "aurora_global_cluster" {
  type = object({
    /// The name of an existing global Aurora cluster to join. Cannot be used with `name`
    ///
    /// @since 1.0.0
    join_existing_global_cluster = optional(string)
    /// Specify the name of the global cluster to be created. Cannot be used with `join_existing_global_cluster`
    ///
    /// @since 1.0.0
    name                         = optional(string)
  })
  description = <<EOT
    Creates new or join existing Aurora Global cluster. Must be used with an `"aurora-*"` engine type

    @since 1.0.0
  EOT
  default     = null
}

variable "auto_scaling_policies" {
  type = map(object({
    /// The cloudwatch metric to monitor for scaling. Must specify one of the following.
    ///
    /// @since 2.0.0
    target_metric = object({
      /// The average value of the CPUUtilization metric in CloudWatch across all Aurora Replicas in the Aurora DB cluster.
      ///
      /// @since 2.0.0
      average_cpu_utilization_of_aurora_replicas = optional(number, null)
      /// The average value of the DatabaseConnections metric in CloudWatch across all Aurora Replicas in the Aurora DB cluster.
      ///
      /// @since 2.0.0
      average_connections_of_aurora_replicas     = optional(number, null)
    })
    /// Allow this Auto Scaling policy to remove Aurora Replicas. Aurora Replicas created by you are not removed by Auto Scaling.
    ///
    /// @since 2.0.0
    enable_scale_in           = optional(bool, true)
    /// Specify the maximum number of Aurora Replicas to maintain. Up to 15 Aurora Replicas are supported.
    ///
    /// @since 2.0.0
    maximum_capacity          = optional(number, 15)
    /// Specify the minimum number of Aurora Replicas to maintain.
    ///
    /// @since 2.0.0
    minimum_capacity          = optional(number, 1)
    /// Specify the number of seconds to wait between scale-in actions.
    ///
    /// @since 2.0.0
    scale_in_cooldown_period  = optional(string, "5 minutes")
    /// Specify the number of seconds to wait between scale-out actions.
    ///
    /// @since 2.0.0
    scale_out_cooldown_period = optional(string, "5 minutes")
  }))
  description = <<EOT
    Manages multiple auto scaling policies. Only applicable to Aurora clusters.

    @example "Aurora Regional Cluster" #aurora-regional-cluster
    @since 2.0.0
  EOT
  default     = {}
}

variable "cloudwatch_log_exports" {
  type        = list(string)
  description = <<EOT
    Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine).

    - MySQL and MariaDB: `audit`, `error`, `general`, `slowquery`
    - PostgreSQL: `postgresql`.

    @since 1.0.0
  EOT
  default     = null
}

variable "cluster_instances" {
  type = map(object({
    /// Additional tags for the individual cluster instance
    ///
    /// @since 1.0.0
    additional_tags    = optional(map(string), {})
    /// Specify the name of the DB parameter group to be associated to the instance.
    ///
    /// @since 1.0.0
    db_parameter_group = optional(string)
    /// Default 0. [Failover Priority][aurora-failover-priority] setting on instance level. The reader who has lower tier has higher priority to get promoted to writer.
    ///
    /// @link {aurora-failover-priority} https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html#Aurora.Managing.FaultTolerance
    /// @since 1.0.0
    failover_priority  = optional(number)
    /// Specify the DB instance class for the individual instance. Do not use for serverless cluster.
    ///
    /// @example "Aurora Global Cluster" #aurora-global-cluster
    /// @since 1.0.0
    instance_class     = optional(string)

    /// Configures RDS maintenance options. If not specified, the cluster level options will be used.
    ///
    /// @since 2.0.0
    maintenance_config = optional(object({
      /// Window to perform maintenance in (in UTC). Syntax: `"ddd:hh24:mi-ddd:hh24:mi"`. For example `"Mon:00:00-Mon:03:00"`.
      ///
      /// @since 2.0.0
      window                            = optional(string, null)
      /// Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window
      ///
      /// @since 2.0.0
      enable_auto_minor_version_upgrade = optional(bool, null)
    }), {})

    /// Configures RDS monitoring options for individual cluster instances
    ///
    /// @since 2.0.0
    monitoring_config = optional(object({
      /// Configures multiple Cloudwatch alarms.
      ///
      /// @example "Cloudwatch Alarms" #cloudwatch-alarms
      /// @since 2.0.0
      cloudwatch_alarms = optional(map(object({
        /// The metric to monitor. Please refer to [this document][aurora-cloudwatch-metrics] for more information
        ///
        /// @link {aurora-cloudwatch-metrics} https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMonitoring.Metrics.html
        /// @since 2.0.0
        metric_name            = string
        /// The expression in `<statistic> <operator> <unit>` format. For example: `"Average < 50"`
        ///
        /// @since 2.0.0
        expression             = string # statistic comparison_operator threshold
        /// The SNS topic where notification will be sent
        ///
        /// @since 2.0.0
        notification_sns_topic = string
        /// The description of the alarm
        ///
        /// @since 2.0.0
        description            = optional(string, null)
        /// The number of periods over which data is compared to the specified threshold.
        ///
        /// @since 2.0.0
        evaluation_periods     = optional(number, 1)
        /// The period in seconds over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`
        ///
        /// @since 2.0.0
        period                 = optional(string, "1 minute")
      })), {})

      /// Enables [RDS enhanced monitoring][rds-enhanced-monitoring].
      ///
      /// @link {rds-enhanced-monitoring} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.overview.html
      /// @since 2.0.0
      enable_enhanced_monitoring = optional(object({
        /// Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0.
        ///
        /// @enum 0|1|5|10|15|30|60
        /// @since 2.0.0
        interval     = number
        /// ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Please refer to [this documentation][rds-enhanced-monitoring-iam-requirement] for information of the required IAM permissions. One will be created if not specified.
        ///
        /// @link {rds-enhanced-monitoring-iam-requirement} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.Enabling.Prerequisites
        /// @since 2.0.0
        iam_role_arn = optional(string)
      }))

      /// Enables [RDS performance insight][rds-performance-insight]
      ///
      /// @link {rds-performance-insight} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.html
      /// @since 2.0.0
      enable_performance_insight = optional(object({
        /// Amount of time in days to retain Performance Insights data. Valid values are `7`, `731` (2 years) or a `multiple of 31`.
        ///
        /// @since 2.0.0
        retention_period = number
        /// ARN for the KMS key to encrypt Performance Insights data.
        ///
        /// @since 2.0.0
        kms_key_id       = optional(string)
      }))
    }), {})

    /// Configures connectivity options for the individual instance
    ///
    /// @since 1.0.0
    networking_config = optional(object({
      /// The availability zone to deploy the RDS instance in
      ///
      /// @since 1.0.0
      availability_zone    = optional(string)
      /// Specify whether the RDS instance is publicly accessible
      ///
      /// @since 1.0.0
      enable_public_access = optional(bool)
    }))
  }))
  description = <<EOT
    Manages multiple instances for an Aurora cluster. Must be used with an `"aurora-*"` engine type.

    @example "Aurora Regional Cluster" #aurora-regional-cluster
    @since 1.0.0
  EOT
  default     = {}
}

variable "db_name" {
  type        = string
  description = <<EOT
    The name of the database to create when the DB instance or cluster is created. If this parameter is not specified, no database is created.

    @since 1.0.0
  EOT
  default     = null
}

variable "db_cluster_parameter_group" {
  type        = string
  description = <<EOT
    Specify the name of the DB parameter group to be attached to all instances in the cluster

    @since 1.0.0
  EOT
  default     = null
}

variable "db_parameter_group" {
  type        = string
  description = <<EOT
    Specify the name of the DB parameter group to be attached to the instance

    @since 1.0.0
  EOT
  default     = null
}

variable "delete_protection_enabled" {
  type        = bool
  description = <<EOT
    Prevent the instance or cluster from deletion when this value is set to `true`

    @since 1.0.0
  EOT
  default     = false
}

variable "deployment_option" {
  type        = string
  description = <<EOT
    Specify the option for non-aurora deployment. `MultiAZInstance` and `MultiAZCluster` only support the `"mysql"` and `"postgres"` engine type.

    @enum SingleInstance|MultiAZInstance|MultiAZCluster
    @link "MultiAZInstance" https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
    @link "MultiAZCluster" https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html
    @since 1.0.0
  EOT
  default     = "SingleInstance"
}

variable "enable_automated_backup" {
  type = object({
    /// The number of days (1-35) for which automatic backups are kept.
    ///
    /// @since 1.0.0
    retention_period      = number
    /// Indicates whether to copy all of the user-defined tags from the DB instance to snapshots of the DB instance
    ///
    /// @since 1.0.0
    copy_tags_to_snapshot = optional(bool, true)
    /// Daily time range (in UTC) during which automated backups are created. In the `"hh24:mi-hh24:mi"` format. For example `"04:00-09:00"`
    ///
    /// @since 1.0.0
    window                = optional(string)
  })
  description = <<EOT
    Configures RDS automated backup

    @since 1.0.0
  EOT
  default     = null
}

variable "enable_encryption" {
  type = object({
    /// The KMS CMK used to encrypt the DB and storage
    ///
    /// @since 1.0.0
    kms_key_alias = optional(string, "aws/rds")
  })
  description = <<EOT
    Enables [RDS DB encryption][rds-db-encryption] to encrypt the DB instance's underlying storage

    @link {rds-db-encryption} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
    @since 1.0.0
  EOT
  default     = null
}

variable "instance_class" {
  type        = string
  description = <<EOT
    The compute and memory capacity of the DB instance, for example `"db.m5.large"`. For the full list of DB instance classes, please refer to [DB instance class][db-instance-class] and [Aurora DB instance class][aurora-db-instance-class]

    @link {db-instance-class} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
    @link {aurora-db-instance-class} https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
    @since 1.0.0
  EOT
  default     = null
}

variable "maintenance_config" {
  type = object({
    /// Window to perform maintenance in (in UTC). Syntax: `"ddd:hh24:mi-ddd:hh24:mi"`. For example `"Mon:00:00-Mon:03:00"`.
    ///
    /// @since 1.0.0
    window                            = string
    /// Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window
    ///
    /// @since 1.0.0
    enable_auto_minor_version_upgrade = optional(bool, true)
  })
  description = <<EOT
    Configures RDS maintenance options

    @since 1.0.0
  EOT
  default     = null
}

variable "monitoring_config" {
  type = object({
    /// Configures multiple Cloudwatch alarms.
    ///
    /// @example "Cloudwatch Alarms" #cloudwatch-alarms
    /// @since 2.0.0
    cloudwatch_alarms = optional(map(object({
      /// The metric to monitor. Please refer to [this document][rds-cloudwatch-metrics] for more information
      ///
      /// @link {rds-cloudwatch-metrics} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html
      /// @since 2.0.0
      metric_name            = string
      /// The expression in `<statistic> <operator> <unit>` format. For example: `"Average < 50"`
      ///
      /// @since 2.0.0
      expression             = string # statistic comparison_operator threshold
      /// The SNS topic where notification will be sent
      ///
      /// @since 2.0.0
      notification_sns_topic = string
      /// The description of the alarm
      ///
      /// @since 2.0.0
      description            = optional(string, null)
      /// The number of periods over which data is compared to the specified threshold.
      ///
      /// @since 2.0.0
      evaluation_periods     = optional(number, 1)
      /// The period in seconds over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`
      ///
      /// @since 2.0.0
      period                 = optional(string, "1 minute")
    })), {})

    /// The mode of Database Insights that is enabled for the cluster or the instance.
    ///
    /// @enum standard|advanced
    /// @since 1.0.0
    database_insights = optional(string, "standard")

    /// Enables [RDS enhanced monitoring][rds-enhanced-monitoring]. If this is enabled when using a cluster setup, you can no longer enable enhanced monitoring in each individual cluster instances.
    ///
    /// @link {rds-enhanced-monitoring} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.overview.html
    /// @since 1.0.0
    enable_enhanced_monitoring = optional(object({
      /// Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0.
      ///
      /// @enum 0|1|5|10|15|30|60
      /// @since 1.0.0
      interval     = number
      /// ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Please refer to [this documentation][rds-enhanced-monitoring-iam-requirement] for information of the required IAM permissions. One will be created if not specified.
      ///
      /// @link {rds-enhanced-monitoring-iam-requirement} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.Enabling.Prerequisites
      /// @since 1.0.0
      iam_role_arn = optional(string)
    }))

    /// Enables [RDS performance insight][rds-performance-insight]
    ///
    /// @link {rds-performance-insight} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.html
    /// @since 1.0.0
    enable_performance_insight = optional(object({
      /// Amount of time in days to retain Performance Insights data. Valid values are `7`, `731` (2 years) or a `multiple of 31`.
      ///
      /// @since 1.0.0
      retention_period = number
      /// ARN for the KMS key to encrypt Performance Insights data.
      ///
      /// @since 1.0.0
      kms_key_id       = optional(string)
    }))
  })
  description = <<EOT
    Configures RDS monitoring options

    @since 1.0.0
  EOT
  default     = {}
}

variable "option_group" {
  type        = string
  description = <<EOT
    Specify the name of the [option group][rds-option-group] to be attached to the instance

    @link {rds-option-group} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html
    @since 1.0.0
  EOT
  default     = null
}

variable "proxies" {
  type = map(object({
    /// Managers multiple authentication configurations. The key of the map will be the Secrets Manager secrets representing the credentials for database user accounts that the proxy can use.
    ///
    /// @since 1.1.0
    authentications = map(object({
      /// The method that the proxy uses to authenticate connections from clients.
      ///
      /// @enum MYSQL_CACHING_SHA2_PASSWORD|MYSQL_NATIVE_PASSWORD|POSTGRES_SCRAM_SHA_256|POSTGRES_MD5
      /// @since 1.1.0
      client_authentication_type = string
      /// Whether to require or disallow Amazon Web Services Identity and Access Management (IAM) authentication for connections to the proxy
      ///
      /// @since 1.1.0
      allow_iam_authentication   = optional(bool, false)
    }))

    /// One or more RDS security groups to allow access to your proxy
    ///
    /// @since 1.1.0
    security_group_ids = list(string)
    /// List of subnets the database can use in the VPC that you selected. A minimum of 2 subnets in different Availability Zones is required for the proxy.
    ///
    /// @since 1.1.0
    subnet_ids         = list(string)

    /// Manages additional endpoints beside the default
    ///
    /// @since 1.1.0
    additional_endpoints = optional(map(object({
      /// One or more RDS security groups to allow access to your proxy. If not specified, the security_group_ids of the proxy will be used.
      ///
      /// @since 1.1.0
      security_group_ids = optional(list(string), null)
      /// List of subnets the database can use in the VPC that you selected. A minimum of 2 subnets in different Availability Zones is required for the proxy. If not specified, the subnet_ids of the proxy will be used.
      ///
      /// @since 1.1.0
      subnet_ids         = optional(list(string), null)
      /// Defines how the workload for this proxy endpoint will be used.
      ///
      /// @enum READ_WRITE|READ_ONLY
      /// @since 1.1.0
      target_role        = optional(string, "READ_WRITE")
    })), null)

    /// With enhanced logging, details of queries processed by the proxy are logged and published to CloudWatch Logs.
    ///
    /// @since 1.1.0
    activate_enhanced_logging        = optional(bool, false)
    /// Additional tags that are attached to the proxy
    ///
    /// @since 1.1.0
    additional_tags                  = optional(map(string), {})
    /// ARN of the IAM role the proxy will use to access the AWS Secrets Manager secrets specified in `authentications`. If unspecified, an IAM role will be created with read permissions to all the secrets specified in `authentications`.
    ///
    /// @since 1.1.0
    iam_role_arn                     = optional(string, null)
    /// Idle connection from your application are closed after the specified time. Valid value: `"1 minute" - "8 hours"`
    ///
    /// @since 1.1.0
    idle_client_connection_timeout   = optional(string, "30 minutes")
    /// whether Transport Layer Security (TLS) encryption is required for connections to the proxy
    ///
    /// @since 1.1.0
    require_transport_layer_security = optional(bool, false)
    /// Manages the default target group's configuration
    ///
    /// @since 1.1.0
    target_group_config = optional(object({
      /// Timeout for borrowing DB connection from the pool. Valid values: `"1 second" - "5 minutes"`
      ///
      /// @since 1.1.0
      connection_borrow_timeout           = optional(string, "2 minutes")
      /// Specify the maximum allowed connections, as a percentage of the maximum connection limit of your database. For example, if you have set the maximum connections to 5,000 connections, specifying `50` allows your proxy to create up to 2,500 connections to the database.
      ///
      /// @since 1.1.0
      connection_pool_maximum_connections = optional(number, 100)
      /// Specify one or more SQL statements to set up the initial session state for each connection. Separate statements with semicolons.
      ///
      /// @since 1.1.0
      initalization_query                 = optional(string, null)
      /// Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool. For Aurora MySQL, it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster used by the target group.
      ///
      /// @since 1.1.0
      max_idle_connections_percent        = optional(number, 50)
      /// Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in the list exempts that class of SQL operations from the pinning behavior. This setting is only supported for MySQL engine family databases.
      ///
      /// @enum EXCLUDE_VARIABLE_SETS
      /// @since 1.1.0
      session_pinning_filters             = optional(list(string), null)
    }), {})
  }))
  description = <<EOT
    Manages multiple RDS proxies that are associated to the DB cluster or instance.

    @example "RDS Proxies" #rds-proxies
    @since 1.1.0
  EOT
  default     = {}
}

variable "restore" {
  type = object({
    /// The snapshot ARN from which RDS restored
    ///
    /// @since 2.1.0
    from_snapshot = optional(string, null)
  })
  description = <<EOT
    Restore RDS cluster or instance from a particular source.

    @since 2.1.0
  EOT
  default     = {}
}

variable "serverless_capacity" {
  type = object({
    /// Specify the minimum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory
    ///
    /// @since 1.0.0
    min_acus = number
    /// Specify the maximum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory. Must be greater than `min_acus`, if unspecified, the value of `min_acus` will be used.
    ///
    /// @since 1.0.0
    max_acus = optional(number)
  })
  description = <<EOT
    Specify the capacity range of the serverless instance. Must be used with `instance_class = "db.serverless"` and an `"aurora-*"` engine type. Refer to [this documentation][aurora-capacity-unit] for more details.

    @example "Aurora Global Cluster" #aurora-global-cluster
    @link {aurora-capacity-unit} https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html
    @since 1.0.0
  EOT
  default     = null
}

variable "skip_final_snapshot" {
  type        = bool
  description = <<EOT
    Determines whether a final DB snapshot is created before the DB cluster is deleted

    @since 1.0.0
  EOT
  default     = false
}

variable "storage_config" {
  /// Specify the storage type.
  ///
  /// @enum gp3|io1
  /// @since 1.0.0
  type = object({
    /// The allocated storage in gibibytes
    ///
    /// @since 1.0.0
    allocated_storage     = number
    /// Specify the storage type
    ///
    /// @enum gp3|io1
    /// @since 1.0.0
    type                  = string
    /// When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to allocated_storage or `0` to disable Storage Autoscaling
    ///
    /// @since 1.0.0
    max_allocated_storage = optional(number)
    /// The amount of provisioned IOPS. Can only be set when `type` is `"io1"` or `"gp3"`. Please refer to [this documentation][rds-provisioned-iops] for more details.
    ///
    /// @link {rds-provisioned-iops} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage
    /// @since 1.0.0
    provisioned_iops      = optional(number)
    /// The storage throughput value for the DB instance. Can only be set when `type = "gp3"`. Please refer to [this documentation][rds-storage-throughput] for more details.
    ///
    /// @link {rds-storage-throughput} https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage
    /// @since 1.0.0
    storage_throughput    = optional(number)
  })
  description = <<EOT
    Configures RDS storage options

    @since 1.0.0
  EOT
  default     = null
}
