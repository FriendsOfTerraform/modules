# Relational Database Service Module

This module will build and configure an [RDS](https://aws.amazon.com/rds/) instance or [Aurora](https://aws.amazon.com/rds/aurora/) cluster with additional readers

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Multi-AZ Instance](#multi-az-instance)
    - [Multi-AZ Cluster](#multi-az-cluster)
    - [Aurora Regional Cluster](#aurora-regional-cluster)
    - [Aurora Global Cluster](#aurora-global-cluster)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "rds_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v1.0.0"

  engine = {
    type    = "mysql"
    version = "8.0.34"
  }

  name = "singleinstance"

  authentication_config = {
    db_master_account = {
      username                           = "admin"
      manage_password_in_secrets_manager = true
    }
  }

  instance_class = "db.m5d.large"

  storage_config = {
    type              = "gp3"
    allocated_storage = 200
  }

  networking_config = {
    db_subnet_group_name = "db-subnet-group"
    security_group_ids   = ["sg-00ce17012345abcde"]
  }

  db_name = "demo"
}
```

### Multi-AZ Instance

```terraform
module "multiazinstance_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v1.0.0"

  engine = {
    type    = "mysql"
    version = "8.0.34"
  }

  deployment_option = "MultiAZInstance"
  name              = "multiazinstance"

  authentication_config = {
    db_master_account = {
      username                           = "admin"
      manage_password_in_secrets_manager = true
    }
  }

  instance_class = "db.m5d.large"

  storage_config = {
    type                  = "gp3"
    allocated_storage     = 2000
    max_allocated_storage = 10000
    provisioned_iops      = 12000
    storage_throughput    = 1000
  }

  networking_config = {
    db_subnet_group_name = "db-subnet-group"
    security_group_ids   = ["sg-00ce17012345abcde"]
  }

  monitoring_config = {
    enable_enhanced_monitoring = {
      interval     = 60
      iam_role_arn = "arn:aws:iam::111122223333:role/rds-monitoring-role"
    }

    enable_performance_insight = {
      retention_period = 7
    }
  }

  db_name = "demo"

  enable_automated_backup = {
    retention_period      = 7
    window                = "00:00-06:00" #PST 1700-2300
    copy_tags_to_snapshot = true
  }

  cloudwatch_log_exports = ["audit", "error", "general", "slowquery"]

  maintenance_config = {
    enable_auto_minor_version_upgrade = true
    window                            = "sat:07:00-sat:15:00" #PST saturday 0000 - 0800
  }
}
```

### Multi-AZ Cluster

```terraform
module "multiazcluster_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v1.0.0"

  engine = {
    type    = "mysql"
    version = "8.0.34"
  }

  deployment_option = "MultiAZCluster"
  name              = "multiazcluster-demo"

  authentication_config = {
    db_master_account = {
      username                           = "admin"
      manage_password_in_secrets_manager = true
    }
  }

  instance_class = "db.m5d.large"

  # Multi-AZ cluster only supports provisioned IOPS storage
  storage_config = {
    type              = "io1"
    allocated_storage = 400
    provisioned_iops  = 3000
  }

  networking_config = {
    db_subnet_group_name = "test-subnet-group"
    security_group_ids   = ["sg-00ce17012345abcde"]
  }
}
```

### Aurora Regional Cluster

```terraform
module "aurora_regional_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v1.0.0"

  engine = {
    type    = "aurora-mysql"
    version = "8.0.mysql_aurora.3.04.0"
  }

  name = "aurora-regional-demo"

  authentication_config = {
    db_master_account = {
      username                           = "admin"
      manage_password_in_secrets_manager = true
    }

    iam_database_authentication = {
      enabled = true

      # Creates IAM policies to allow connection to this RDS cluster
      # The name of the db users must already existed in the DB
      # IAM policies must be attached to an IAM principal
      create_iam_policies_for_db_users = ["peter", "jane"]
    }
  }

  instance_class = "db.t3.medium"

  networking_config = {
    db_subnet_group_name = "db-subnet-group"
    security_group_ids   = ["sg-00ce17012345abcde"]
  }

  db_name = "demo"

  enable_automated_backup = {
    retention_period      = 7
    window                = "00:00-06:00" #PST 1700-2300
    copy_tags_to_snapshot = true
  }

  cloudwatch_log_exports = ["audit", "error", "general", "slowquery"]

  maintenance_config = {
    window = "sat:07:00-sat:15:00" #PST saturday 0000 - 0800
  }

  cluster_instances = {
    # The key of the map will be the instance's name
    primary = {}
    secondary = {
      networking_config = { availability_zone = "us-east-1b" }
    }
  }
}
```

### Aurora Global Cluster

```terraform
module "aurora_global_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v1.0.0"

  # Creates a new global cluster
  aurora_global_cluster = {
    name = "global-cluster-demo"
  }

  engine = {
    type    = "aurora-mysql"
    version = "8.0.mysql_aurora.3.04.0"
  }

  name = "us-east-1-cluster"

  authentication_config = {
    db_master_account = {
      username                           = "admin"
      manage_password_in_secrets_manager = true
    }
  }

  instance_class = "db.serverless"

  serverless_capacity = {
    max_acus = 50
    min_acus = 20
  }

  networking_config = {
    db_subnet_group_name = "db-subnet-group"
    security_group_ids   = ["sg-00ce17012345abcde"]
  }

  db_name = "demo"

  enable_automated_backup = {
    retention_period      = 7
    window                = "00:00-06:00" #PST 1700-2300
    copy_tags_to_snapshot = true
  }

  cloudwatch_log_exports = ["audit", "error", "general", "slowquery"]

  maintenance_config = {
    window = "sat:07:00-sat:15:00" #PST saturday 0000 - 0800
  }

  cluster_instances = {
    # The key of the map will be the instance's name
    primary   = {}
    secondary = {}
  }
}
```

## Argument Reference

### Mandatory

- (object) **`authentication_config`** _[since v1.0.0]_

    Configures RDS authentication methods

    - (object) **`db_master_account`** _[since v1.0.0]_

        Manages the DB master account

        - (string) **`username`** _[since v1.0.0]_

            Username for the master DB user

        - (string) **`customer_kms_key_id = null`** _[since v1.0.0]_

            Specify the KMS key to encrypt the master password in secrets manager. If not specified, the default KMS key for your AWS account is used. Used when `manage_password_in_secrets_manager = true`

        - (bool) **`manage_password_in_secrets_manager = false`** _[since v1.0.0]_

            Set to true to allow RDS to [manage the master user password in Secrets Manager][manage-password-in-secrets-manager]. Mutually exclusive with `password`. This feature does not support Aurora global cluster.

        - (string) **`password = null`** _[since v1.0.0]_

            Password for the master DB user. Mutually exclusive with `manage_password_in_secrets_manager`

    - (bool) **`iam_database_authentication = null`** _[since v1.0.0]_

        Configures [AWS Identity and Access Management (IAM) accounts to database accounts][rds-iam-db-authentication]. Cannot be used when `deployment_option = "MultiAZCluster"`. Plesae refer to the following documentations for instruction to each DB engine.

        - [MySQL, MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html)
        - [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html)

      - (bool) **`enabled = true`** _[since v1.0.0]_

          Specify whether IAM DB authentication is enabled. [See example](#aurora-regional-cluster)

      - (list(string)) **`create_iam_policies_for_db_users = []`** _[since v1.0.0]_

          Specify a list of DB user names to create IAM policies for RDS IAM Authentication. This will allow an IAM principal such as an IAM role to request authentication token for the specific DB user. Please refer to [this documentation][rds-iam-authentication-policy] for more information.

- (object) **`engine`** _[since v1.0.0]_

    Configures RDS engine options

    - (string) **`type`** _[since v1.0.0]_

        Specify the engine type, This module currently supports: `"aurora-mysql"`, `"aurora-postgresql"`, `"mysql"`, `"postgres"`, `"mariadb`

    - (string) **`version`** _[since v1.0.0]_

        Specify the engine version. You can get a list of engine version with `aws rds describe-db-engine-versions --engine aurora-mysql --query DBEngineVersions[].[EngineVersion]`

- (string) **`instance_class`** _[since v1.0.0]_

    The compute and memory capacity of the DB instance, for example `"db.m5.large"`. For the full list of DB instance classes, please refer to [DB instance class][db-instance-class] and [Aurora DB instance class][aurora-db-instance-class]

- (string) **`name`** _[since v1.0.0]_

    Specify the name of the RDS instance or the RDS cluster

- (object) **`networking_config`** _[since v1.0.0]_

    Configures RDS connectivity options

    - (string) **`db_subnet_group_name`** _[since v1.0.0]_

        Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. A DB subnet group with at least three AZs must be specified if `deployment_option = "MultiAZCluster"`

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        List of VPC security groups to associate to the RDS instance or cluster

    - (string) **`availability_zone = null`** _[since v1.0.0]_

        The availability zone to deploy the RDS instance in

    - (string) **`ca_cert_identifier = null`** _[since v1.0.0]_

        The certificate authority (CA) is the certificate that identifies the root CA at the top of the certificate chain. The CA signs the DB server certificate, which is installed on each DB instance. The DB server certificate identifies the DB instance as a trusted server. Please refer to [this documentation][rds-ca] for valid values. Defaults to `"rds-ca-2019"`. Refers to the following documentations for requirements to connect to each DB engine with SSL.

        - [MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mariadb.html)
        - [MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mysql.html)
        - [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html)

    - (bool) **`enable_ipv6 = false`** _[since v1.0.0]_

        Specify whether the RDS instance or cluster supports IPv6

    - (bool) **`enable_public_access = false`** _[since v1.0.0]_

        Specify whether the RDS instance or cluster is publicly accessible

    - (string) **`port = null`** _[since v1.0.0]_

        Specify the port on which the DB accepts connections.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the RDS instance or cluster

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (object) **`aurora_global_cluster = null`** _[since v1.0.0]_

    Creates new or join existing Aurora Global cluster. Must be used with an `"aurora-*"` engine type

    - (string) **`join_existing_global_cluster = null`** _[since v1.0.0]_

        The name of an existing global Aurora cluster to join. Cannot be used with `name`

    - (string) **`name = null`** _[since v1.0.0]_

        Specify the name of the global cluster to be created. Cannot be used with `join_existing_global_cluster`

- (list(string)) **`cloudwatch_log_exports = null`** _[since v1.0.0]_

    Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine). MySQL and MariaDB: `"audit"`, `"error"`, `"general"`, `"slowquery"`. PostgreSQL: `"postgresql"`.

- (map(object)) **`cluster_instances = {}`** _[since v1.0.0]_

    Manages multiple instances for an Aurora cluster. Must be used with an `"aurora-*"` engine type. See [example](#aurora-regional-cluster)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the individual cluster instance

    - (string) **`db_parameter_group = null`** _[since v1.0.0]_

        Specify the name of the DB parameter group to be associated to the instance.

    - (number) **`failover_priority = null`** _[since v1.0.0]_

        Default 0. [Failover Priority][aurora-failover-priority] setting on instance level. The reader who has lower tier has higher priority to get promoted to writer.

    - (string) **`instance_class = null`** _[since v1.0.0]_

        Specify the DB instance class for the individual instance. Do not use for serverless cluster. See [example](#aurora-global-cluster)

    - (object) **`networking_config = null`** _[since v1.0.0]_

        Configures connectivity options for the individual instance

        - (string) **`availability_zone = null`** _[since v1.0.0]_

            The availability zone to deploy the RDS instance in

        - (bool) **`enable_public_access = null`** _[since v1.0.0]_

            Specify whether the RDS instance is publicly accessible

- (string) **`db_name = null`** _[since v1.0.0]_

    The name of the database to create when the DB instance or cluster is created. If this parameter is not specified, no database is created.

- (string) **`db_cluster_parameter_group = null`** _[since v1.0.0]_

    Specify the name of the DB parameter group to be attached to all instances in the cluster

- (string) **`db_parameter_group = null`** _[since v1.0.0]_

    Specify the name of the DB parameter group to be attached to the instance

- (bool) **`delete_protection_enabled = false`** _[since v1.0.0]_

    Prevent the instance or cluster from deletion when this value is set to `true`

- (string) **`deployment_option = SingleInstance`** _[since v1.0.0]_

    Specify the option for non-aurora deployment. Valid values are: `"SingleInstance"`, ["MultiAZInstance"][rds-multi-az-instance], ["MultiAZCluster"][rds-multi-az-cluster]. `MultiAZInstance` and `MultiAZCluster` only support the `"mysql"` and `"postgres"` engine type.

- (object) **`enable_automated_backup = null`** _[since v1.0.0]_

    Configures RDS automated backup

    - (number) **`retention_period`** _[since v1.0.0]_

        The number of days (1-35) for which automatic backups are kept.

    - (bool) **`copy_tags_to_snapshot = true`** _[since v1.0.0]_

        Indicates whether to copy all of the user-defined tags from the DB instance to snapshots of the DB instance

    - (string) **`window = null`** _[since v1.0.0]_

        Daily time range (in UTC) during which automated backups are created. In the `"hh24:mi-hh24:mi"` format. For example `"04:00-09:00"`

- (object) **`enable_encryption = null`** _[since v1.0.0]_

    Enables [RDS DB encryption][rds-db-encryption] to encrypt the DB instance

    - (string) **`kms_key_arn`** _[since v1.0.0]_

        The KMS CMK used to encrypt the DB and storage

- (object) **`maintenance_config = null`** _[since v1.0.0]_

    Configures RDS maintenance options

    - (string) **`window`** _[since v1.0.0]_

        Window to perform maintenance in (in UTC). Syntax: `"ddd:hh24:mi-ddd:hh24:mi"`. For example `"Mon:00:00-Mon:03:00"`.

    - (bool) **`enable_auto_minor_version_upgrade = true`** _[since v1.0.0]_

        Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window

- (object) **`monitoring_config = null`** _[since v1.0.0]_

    Configures RDS monitoring options

    - (object) **`enable_enhanced_monitoring = null`** _[since v1.0.0]_

        Enables [RDS enhanced monitoring][rds-enhanced-monitoring]

        - (string) **`iam_role_arn`** _[since v1.0.0]_

            ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Please refer to [this documentation][rds-enhanced-monitoring-iam-requirement] for information of the required IAM permissions.

        - (number) **`interval`** _[since v1.0.0]_

            Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: `0`, `1`, `5`, `10`, `15`, `30`, `60`.

    - (object) **`enable_performance_insight = null`** _[since v1.0.0]_

        Enables [RDS performance insight][rds-performance-insight]

        - (number) **`retention_period`** _[since v1.0.0]_

            Amount of time in days to retain Performance Insights data. Valid values are `7`, `731` (2 years) or a `multiple of 31`.

        - (string) **`kms_key_id = null`** _[since v1.0.0]_

            ARN for the KMS key to encrypt Performance Insights data.

- (string) **`option_group = null`** _[since v1.0.0]_

    Specify the name of the [option group][rds-option-group] to be attached to the instance

- (object) **`serverless_capacity = null`** _[since v1.0.0]_

    Specify the capacity range of the serverless instance. Must be used with `instance_class = "db.serverless"` and an `"aurora-*"` engine type, [see example](#aurora-global-cluster). Refer to [this documentation][aurora-capacity-unit] for more details.

    - (number) **`min_acus`** _[since v1.0.0]_

        Specify the minimum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory

    - (number) **`max_acus = null`** _[since v1.0.0]_

        Specify the maximum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory. Must be greater than `min_acus`, if unspecified, the value of `min_acus` will be used.

- (bool) **`skip_final_snapshot = null`** _[since v1.0.0]_

    Determines whether a final DB snapshot is created before the DB cluster is deleted

- (object) **`storage_config = null`** _[since v1.0.0]_

    Configures RDS storage options

    - (number) **`allocated_storage`** _[since v1.0.0]_

        The allocated storage in gibibytes

    - (string) **`type`** _[since v1.0.0]_

        Specify the storage type. Valid values are: `"gp3"` and `"io1"`

    - (number) **`max_allocated_storage = null`** _[since v1.0.0]_

        When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to allocated_storage or `0` to disable Storage Autoscaling

    - (number) **`provisioned_iops = null`** _[since v1.0.0]_

        The amount of provisioned IOPS. Can only be set when `type` is `"io1"` or `"gp3"`. Please refer to [this documentation][rds-provisioned-iops] for more details.

    - (number) **`storage_throughput = null`** _[since v1.0.0]_

        The storage throughput value for the DB instance. Can only be set when `type = "gp3"`. Please refer to [this documentation][rds-storage-throughput] for more details.

## Outputs

- (string) **`aurora_cluster_endpoint`** _[since v1.0.0]_

    DNS address of the Writer instance

- (list(string)) **`aurora_cluster_members`** _[since v1.0.0]_

    List of RDS Instances that are a part of this Aurora cluster

- (string) **`aurora_cluster_reader_endpoint`** _[since v1.0.0]_

    Read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

- (string) **`aurora_global_cluster_arn`** _[since v1.0.0]_

    The ARN of the Aurora global cluster created by this module

- (string) **`aurora_global_cluster_identifier`** _[since v1.0.0]_

    The name of the Aurora global cluster created by this module

- (string) **`cluster_arn`** _[since v1.0.0]_

    The ARN of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

- (string) **`cluster_identifier`** _[since v1.0.0]_

    The name of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

- (object) **`master_user_secret`** _[since v1.0.0]_

    Retrive master user secret. Only available when `authentication_config.db_master_account.manage_password_in_secrets_manager = true`

    - (string) **`kms_key_id`** _[since v1.0.0]_

        Amazon Web Services KMS key identifier that is used to encrypt the secret.

    - (string) **`secret_arn`** _[since v1.0.0]_

        Amazon Resource Name (ARN) of the secret.

    - (string) **`secret_status`** _[since v1.0.0]_

        Status of the secret. Value can be: `"creating"`, `"active"`, `"rotating"`, or `"impaired"`.

- (map(string)) **`rds_connect_iam_policy_arns`** _[since v1.0.0]_

    The map of IAM policy ARNs for RDS connect. Only available when `authentication_config.iam_database_authentication.enabled = true`

[aurora-capacity-unit]:https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html
[aurora-db-instance-class]:https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
[aurora-failover-priority]:https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html#Aurora.Managing.FaultTolerance
[db-instance-class]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
[manage-password-in-secrets-manager]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html
[rds-ca]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.RegionCertificateAuthorities
[rds-cluster-parameter-group]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithDBClusterParamGroups.html
[rds-instance-parameter-group]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithDBInstanceParamGroups.html
[rds-db-encryption]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
[rds-enhanced-monitoring]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.overview.html
[rds-enhanced-monitoring-iam-requirement]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.Enabling.Prerequisites
[rds-iam-authentication-policy]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
[rds-iam-db-authentication]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html
[rds-multi-az-instance]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
[rds-multi-az-cluster]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html
[rds-performance-insight]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.html
[rds-provisioned-iops]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage
[rds-option-group]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html
[rds-storage-throughput]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage
