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
    - [RDS Proxies](#rds-proxies)
    - [Cloudwatch Alarms](#cloudwatch-alarms)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

```terraform
module "rds_demo" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

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
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

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
      interval = 60
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
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

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
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

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

  # Manages multiple auto scaling policies
  auto_scaling_policies = {
    # The keys of the map are the policy names
    scale_by_cpu = {
      target_metric = {
        average_cpu_utilization_of_aurora_replicas = 60
      }
    }
    scale_by_number_of_connections = {
      target_metric = {
        average_connections_of_aurora_replicas = 100
      }
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
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

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

### RDS Proxies

```terraform
module "rds_proxies" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

  name           = "demo-db"
  instance_class = "db.t4g.medium"

  engine = {
    type    = "postgres"
    version = "14.17"
  }

  authentication_config = {
    db_master_account = {
      username                           = "postgres"
      manage_password_in_secrets_manager = true
    }
  }

  networking_config = {
    db_subnet_group_name = "default"
    security_group_ids   = ["sg-01230e2abcdef"]
    ca_cert_identifier   = "rds-ca-rsa2048-g1"
  }

  proxies = {
    # The keys of the map are the proxies' name
    demo-proxy = {
      security_group_ids = ["sg-04e232731f6abcdef"]
      subnet_ids         = ["subnet-abcdef012345", "subnet-543210fedcba"]

      # Manages multiple authentications
      authentications = {
        # The keys of the map are secrets manager arn for the DB users
        "arn:aws:secretsmanager:us-east-1:111122223333:secret:demo-db-user" = { client_authentication_type = "POSTGRES_SCRAM_SHA_256" }
      }

      # You can create multiple additional endpoints beside the default one
      additional_endpoints = {
        # The keys of the map are the endpoints' name
        demo-proxy-read-only = { target_role = "READ_ONLY" }
      }
    }
  }
}
```

### Cloudwatch Alarms

```terraform
module "cloudwatch_alarms" {
  source = "github.com/FriendsOfTerraform/aws-rds.git?ref=v2.1.0"

  name                = "aurora-demo"
  db_name             = "demo"
  instance_class      = "db.t3.medium"
  skip_final_snapshot = true

  engine = {
    type    = "aurora-postgresql"
    version = "14.15"
  }

  cluster_instances = {
    primary = {
      failover_priority = 0

      monitoring_config = {
        cloudwatch_alarms = {
          # The key of the map are the alarms' name
          freeable-memory-anomaly = {
            metric_name            = "FreeableMemory"
            expression             = "average < 1000000000"
            notification_sns_topic = "arn:aws:sns:us-east-1:111122223333:email-admin"
          }

          cpu-utilization = {
            metric_name            = "CPUUtilization"
            expression             = "average >= 85"
            notification_sns_topic = "arn:aws:sns:us-east-1:111122223333:email-admin"
          }
        }
      }
    }

    secondary = {
      failover_priority = 1

      monitoring_config = {
        cloudwatch_alarms = {
          cpu-utilization = {
            metric_name            = "CPUUtilization"
            expression             = "average >= 85"
            notification_sns_topic = "arn:aws:sns:us-east-1:111122223333:email-admin"
          }
        }
      }
    }
  }

  authentication_config = {
    db_master_account = {
      username                           = "postgres"
      manage_password_in_secrets_manager = true
    }
  }

  networking_config = {
    db_subnet_group_name = "default"
    security_group_ids   = ["sg-01234593f7eabcdef"]
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#authenticationconfig">AuthenticationConfig</a>)</code></td>
    <td width="100%">authentication_config</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures RDS authentication methods

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#engine">Engine</a>)</code></td>
    <td width="100%">engine</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures RDS engine options

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the RDS instance or the RDS cluster

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#networkingconfig">NetworkingConfig</a>)</code></td>
    <td width="100%">networking_config</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures RDS connectivity options

    

    

    

    

    
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

Additional tags for the RDS instance or cluster

    

    

    

    

    
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
    <td width="100%">apply_immediately</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies whether any database modifications are applied immediately, or during the next maintenance window. Using `apply_immediately` can result in a brief downtime as the server reboots.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#auroraglobalcluster">AuroraGlobalCluster</a>)</code></td>
    <td width="100%">aurora_global_cluster</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Creates new or join existing Aurora Global cluster. Must be used with an `"aurora-*"` engine type

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#autoscalingpolicies">AutoScalingPolicies</a>))</code></td>
    <td width="100%">auto_scaling_policies</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple auto scaling policies. Only applicable to Aurora clusters.

    

    

    
**Examples:**
- [Aurora Regional Cluster](#aurora-regional-cluster)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">cloudwatch_log_exports</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine).

- MySQL and MariaDB: `audit`, `error`, `general`, `slowquery`
- PostgreSQL: `postgresql`.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#clusterinstances">ClusterInstances</a>))</code></td>
    <td width="100%">cluster_instances</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple instances for an Aurora cluster. Must be used with an `"aurora-*"` engine type.

    

    

    
**Examples:**
- [Aurora Regional Cluster](#aurora-regional-cluster)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">db_cluster_parameter_group</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the name of the DB parameter group to be attached to all instances in the cluster

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">db_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of the database to create when the DB instance or cluster is created. If this parameter is not specified, no database is created.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">db_parameter_group</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the name of the DB parameter group to be attached to the instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">delete_protection_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Prevent the instance or cluster from deletion when this value is set to `true`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">deployment_option</td>
    <td><code>"SingleInstance"</code></td>
</tr>
<tr><td colspan="3">

Specify the option for non-aurora deployment. `MultiAZInstance` and `MultiAZCluster` only support the `"mysql"` and `"postgres"` engine type.

    
**Allowed Values:**
- `SingleInstance`
- `MultiAZInstance`
- `MultiAZCluster`

    

    

    
**Links:**
- [MultiAZInstance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html)
- [MultiAZCluster](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableautomatedbackup">EnableAutomatedBackup</a>)</code></td>
    <td width="100%">enable_automated_backup</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures RDS automated backup

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableencryption">EnableEncryption</a>)</code></td>
    <td width="100%">enable_encryption</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Enables [RDS DB encryption][rds-db-encryption] to encrypt the DB instance's underlying storage

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">instance_class</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The compute and memory capacity of the DB instance, for example `"db.m5.large"`. For the full list of DB instance classes, please refer to [DB instance class][db-instance-class] and [Aurora DB instance class][aurora-db-instance-class]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#maintenanceconfig">MaintenanceConfig</a>)</code></td>
    <td width="100%">maintenance_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures RDS maintenance options

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#monitoringconfig">MonitoringConfig</a>)</code></td>
    <td width="100%">monitoring_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures RDS monitoring options

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">option_group</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the name of the [option group][rds-option-group] to be attached to the instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#proxies">Proxies</a>))</code></td>
    <td width="100%">proxies</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple RDS proxies that are associated to the DB cluster or instance.

    

    

    
**Examples:**
- [RDS Proxies](#rds-proxies)

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#restore">Restore</a>)</code></td>
    <td width="100%">restore</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Restore RDS cluster or instance from a particular source.

    

    

    

    

    
**Since:** 2.1.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#serverlesscapacity">ServerlessCapacity</a>)</code></td>
    <td width="100%">serverless_capacity</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the capacity range of the serverless instance. Must be used with `instance_class = "db.serverless"` and an `"aurora-*"` engine type. Refer to [this documentation][aurora-capacity-unit] for more details.

    

    

    
**Examples:**
- [Aurora Global Cluster](#aurora-global-cluster)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">skip_final_snapshot</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Determines whether a final DB snapshot is created before the DB cluster is deleted

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#storageconfig">StorageConfig</a>)</code></td>
    <td width="100%">storage_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures RDS storage options

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">aurora_cluster_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

DNS address of the Writer instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">aurora_cluster_members</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of RDS Instances that are a part of this Aurora cluster

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">aurora_cluster_reader_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

Read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">aurora_global_cluster_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the Aurora global cluster created by this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">aurora_global_cluster_identifier</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the Aurora global cluster created by this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">cluster_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">cluster_identifier</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the RDS cluster. Only applicable if deploying an `Aurora cluster` or a `Multi-AZ Cluster`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#masterusersecret">MasterUserSecret</a>))</code></td>
    <td width="100%">master_user_secret</td>
    <td></td>
</tr>
<tr><td colspan="3">

Retrieve master user secret. Only available when `authentication_config.db_master_account.manage_password_in_secrets_manager = true`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">rds_connect_iam_policy_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

The map of IAM policy ARNs for RDS connect. Only available when `authentication_config.iam_database_authentication.enabled = true`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### AdditionalEndpoints

Manages additional endpoints beside the default

    

    

    

    

    
**Since:** 1.1.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

One or more RDS security groups to allow access to your proxy. If not specified, the security_group_ids of the proxy will be used.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

List of subnets the database can use in the VPC that you selected. A minimum of 2 subnets in different Availability Zones is required for the proxy. If not specified, the subnet_ids of the proxy will be used.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">target_role</td>
    <td><code>"READ_WRITE"</code></td>
</tr>
<tr><td colspan="3">

Defines how the workload for this proxy endpoint will be used.

    
**Allowed Values:**
- `READ_WRITE`
- `READ_ONLY`

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
</tbody></table>



#### AuroraGlobalCluster



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">join_existing_global_cluster</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an existing global Aurora cluster to join. Cannot be used with `name`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the global cluster to be created. Cannot be used with `join_existing_global_cluster`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### AuthenticationConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#dbmasteraccount">DbMasterAccount</a>)</code></td>
    <td width="100%">db_master_account</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages the DB master account

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#iamdatabaseauthentication">IamDatabaseAuthentication</a>)</code></td>
    <td width="100%">iam_database_authentication</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures [AWS Identity and Access Management (IAM) accounts to database accounts][rds-iam-db-authentication]. Cannot be used when `deployment_option = "MultiAZCluster"`. Refer to the following documentations for instruction to each DB engine.

- [MySQL, MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html)
- [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html)

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Authentications

Managers multiple authentication configurations. The key of the map will be the Secrets Manager secrets representing the credentials for database user accounts that the proxy can use.

    

    

    

    

    
**Since:** 1.1.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">client_authentication_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

The method that the proxy uses to authenticate connections from clients.

    
**Allowed Values:**
- `MYSQL_CACHING_SHA2_PASSWORD`
- `MYSQL_NATIVE_PASSWORD`
- `POSTGRES_SCRAM_SHA_256`
- `POSTGRES_MD5`

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_iam_authentication</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether to require or disallow Amazon Web Services Identity and Access Management (IAM) authentication for connections to the proxy

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
</tbody></table>



#### AutoScalingPolicies



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#targetmetric">TargetMetric</a>)</code></td>
    <td width="100%">target_metric</td>
    <td></td>
</tr>
<tr><td colspan="3">

The cloudwatch metric to monitor for scaling. Must specify one of the following.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_scale_in</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Allow this Auto Scaling policy to remove Aurora Replicas. Aurora Replicas created by you are not removed by Auto Scaling.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">maximum_capacity</td>
    <td><code>15</code></td>
</tr>
<tr><td colspan="3">

Specify the maximum number of Aurora Replicas to maintain. Up to 15 Aurora Replicas are supported.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">minimum_capacity</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Specify the minimum number of Aurora Replicas to maintain.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scale_in_cooldown_period</td>
    <td><code>"5 minutes"</code></td>
</tr>
<tr><td colspan="3">

Specify the number of seconds to wait between scale-in actions.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">scale_out_cooldown_period</td>
    <td><code>"5 minutes"</code></td>
</tr>
<tr><td colspan="3">

Specify the number of seconds to wait between scale-out actions.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### CloudwatchAlarms

Configures multiple Cloudwatch alarms.

    

    

    
**Examples:**
- [Cloudwatch Alarms](#cloudwatch-alarms)

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">metric_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The metric to monitor. Please refer to [this document][rds-cloudwatch-metrics] for more information

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">expression</td>
    <td></td>
</tr>
<tr><td colspan="3">

The expression in `<statistic> <operator> <unit>` format. For example: `"Average < 50"`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">notification_sns_topic</td>
    <td></td>
</tr>
<tr><td colspan="3">

The SNS topic where notification will be sent

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the alarm

    

    

    

    

    
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
    <td><code>string</code></td>
    <td width="100%">period</td>
    <td><code>"1 minute"</code></td>
</tr>
<tr><td colspan="3">

The period in seconds over which the specified statistic is applied. Valid values: `"1 minute"` - `"6 hours"`

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>



#### ClusterInstances



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the individual cluster instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">db_parameter_group</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the DB parameter group to be associated to the instance.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">failover_priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

Default 0. [Failover Priority][aurora-failover-priority] setting on instance level. The reader who has lower tier has higher priority to get promoted to writer.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">instance_class</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the DB instance class for the individual instance. Do not use for serverless cluster.

    

    

    
**Examples:**
- [Aurora Global Cluster](#aurora-global-cluster)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#maintenanceconfig">MaintenanceConfig</a>)</code></td>
    <td width="100%">maintenance_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures RDS maintenance options. If not specified, the cluster level options will be used.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#monitoringconfig">MonitoringConfig</a>)</code></td>
    <td width="100%">monitoring_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures RDS monitoring options for individual cluster instances

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#networkingconfig">NetworkingConfig</a>)</code></td>
    <td width="100%">networking_config</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures connectivity options for the individual instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### DbMasterAccount

Manages the DB master account

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">username</td>
    <td></td>
</tr>
<tr><td colspan="3">

Username for the master DB user

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">customer_kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the KMS key to encrypt the master password in secrets manager. If not specified, the default KMS key for your AWS account is used. Used when `manage_password_in_secrets_manager = true`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">manage_password_in_secrets_manager</td>
    <td></td>
</tr>
<tr><td colspan="3">

Set to true to allow RDS to [manage the master user password in Secrets Manager][manage-password-in-secrets-manager]. Mutually exclusive with `password`. This feature does not support Aurora global cluster.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">password</td>
    <td></td>
</tr>
<tr><td colspan="3">

Password for the master DB user. Mutually exclusive with `manage_password_in_secrets_manager`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableAutomatedBackup



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">retention_period</td>
    <td></td>
</tr>
<tr><td colspan="3">

The number of days (1-35) for which automatic backups are kept.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">copy_tags_to_snapshot</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Indicates whether to copy all of the user-defined tags from the DB instance to snapshots of the DB instance

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">window</td>
    <td></td>
</tr>
<tr><td colspan="3">

Daily time range (in UTC) during which automated backups are created. In the `"hh24:mi-hh24:mi"` format. For example `"04:00-09:00"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableEncryption



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_alias</td>
    <td><code>"aws/rds"</code></td>
</tr>
<tr><td colspan="3">

The KMS CMK used to encrypt the DB and storage

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableEnhancedMonitoring

Enables [RDS enhanced monitoring][rds-enhanced-monitoring]. If this is enabled when using a cluster setup, you can no longer enable enhanced monitoring in each individual cluster instances.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">interval</td>
    <td></td>
</tr>
<tr><td colspan="3">

Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0.

    
**Allowed Values:**
- `0`
- `1`
- `5`
- `10`
- `15`
- `30`
- `60`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Please refer to [this documentation][rds-enhanced-monitoring-iam-requirement] for information of the required IAM permissions. One will be created if not specified.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnablePerformanceInsight

Enables [RDS performance insight][rds-performance-insight]

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">retention_period</td>
    <td></td>
</tr>
<tr><td colspan="3">

Amount of time in days to retain Performance Insights data. Valid values are `7`, `731` (2 years) or a `multiple of 31`.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN for the KMS key to encrypt Performance Insights data.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Engine



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the engine type

    
**Allowed Values:**
- `aurora-mysql`
- `aurora-postgresql`
- `mysql`
- `postgres`
- `mariadb`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">version</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the engine version. You can get a list of engine version with `aws rds describe-db-engine-versions --engine aurora-mysql --query DBEngineVersions[].[EngineVersion]`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### IamDatabaseAuthentication

Configures [AWS Identity and Access Management (IAM) accounts to database accounts][rds-iam-db-authentication]. Cannot be used when `deployment_option = "MultiAZCluster"`. Refer to the following documentations for instruction to each DB engine.

- [MySQL, MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html)
- [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html)

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Specify whether IAM DB authentication is enabled.

    

    

    
**Examples:**
- [Aurora Regional Cluster](#aurora-regional-cluster)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">create_iam_policies_for_db_users</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify a list of DB user names to create IAM policies for RDS IAM Authentication. This will allow an IAM principal such as an IAM role to request authentication token for the specific DB user. Please refer to [this documentation][rds-iam-authentication-policy] for more information.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### MaintenanceConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">window</td>
    <td></td>
</tr>
<tr><td colspan="3">

Window to perform maintenance in (in UTC). Syntax: `"ddd:hh24:mi-ddd:hh24:mi"`. For example `"Mon:00:00-Mon:03:00"`.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_auto_minor_version_upgrade</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### MasterUserSecret



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Amazon Web Services KMS key identifier that is used to encrypt the secret.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">secret_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Amazon Resource Name (ARN) of the secret.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">secret_status</td>
    <td></td>
</tr>
<tr><td colspan="3">

Status of the secret

    
**Allowed Values:**
- `creating`
- `active`
- `rotating`
- `impaired`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### MonitoringConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#cloudwatchalarms">CloudwatchAlarms</a>))</code></td>
    <td width="100%">cloudwatch_alarms</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple Cloudwatch alarms.

    

    

    
**Examples:**
- [Cloudwatch Alarms](#cloudwatch-alarms)

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">database_insights</td>
    <td><code>"standard"</code></td>
</tr>
<tr><td colspan="3">

The mode of Database Insights that is enabled for the cluster or the instance.

    
**Allowed Values:**
- `standard`
- `advanced`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableenhancedmonitoring">EnableEnhancedMonitoring</a>)</code></td>
    <td width="100%">enable_enhanced_monitoring</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables [RDS enhanced monitoring][rds-enhanced-monitoring]. If this is enabled when using a cluster setup, you can no longer enable enhanced monitoring in each individual cluster instances.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enableperformanceinsight">EnablePerformanceInsight</a>)</code></td>
    <td width="100%">enable_performance_insight</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables [RDS performance insight][rds-performance-insight]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NetworkingConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">db_subnet_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. A DB subnet group with at least three AZs must be specified if `deployment_option = "MultiAZCluster"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of VPC security groups to associate to the RDS instance or cluster

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">availability_zone</td>
    <td></td>
</tr>
<tr><td colspan="3">

The availability zone to deploy the RDS instance in

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ca_cert_identifier</td>
    <td></td>
</tr>
<tr><td colspan="3">

The certificate authority (CA) is the certificate that identifies the root CA at the top of the certificate chain. The CA signs the DB server certificate, which is installed on each DB instance. The DB server certificate identifies the DB instance as a trusted server. Please refer to [this documentation][rds-ca] for valid values. Defaults to `"rds-ca-2019"`. Refers to the following documentations for requirements to connect to each DB engine with SSL.

- [MariaDB](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mariadb.html)
- [MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/ssl-certificate-rotation-mysql.html)
- [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html)

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_ipv6</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Specify whether the RDS instance or cluster supports IPv6

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_public_access</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Specify whether the RDS instance or cluster is publicly accessible

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">port</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the port on which the DB accepts connections.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Proxies



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#authentications">Authentications</a>))</code></td>
    <td width="100%">authentications</td>
    <td></td>
</tr>
<tr><td colspan="3">

Managers multiple authentication configurations. The key of the map will be the Secrets Manager secrets representing the credentials for database user accounts that the proxy can use.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

One or more RDS security groups to allow access to your proxy

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of subnets the database can use in the VPC that you selected. A minimum of 2 subnets in different Availability Zones is required for the proxy.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#additionalendpoints">AdditionalEndpoints</a>))</code></td>
    <td width="100%">additional_endpoints</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manages additional endpoints beside the default

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">activate_enhanced_logging</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

With enhanced logging, details of queries processed by the proxy are logged and published to CloudWatch Logs.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags that are attached to the proxy

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

ARN of the IAM role the proxy will use to access the AWS Secrets Manager secrets specified in `authentications`. If unspecified, an IAM role will be created with read permissions to all the secrets specified in `authentications`.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">idle_client_connection_timeout</td>
    <td><code>"30 minutes"</code></td>
</tr>
<tr><td colspan="3">

Idle connection from your application are closed after the specified time. Valid value: `"1 minute" - "8 hours"`

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">require_transport_layer_security</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

whether Transport Layer Security (TLS) encryption is required for connections to the proxy

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#targetgroupconfig">TargetGroupConfig</a>)</code></td>
    <td width="100%">target_group_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages the default target group's configuration

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
</tbody></table>



#### Restore



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">from_snapshot</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The snapshot ARN from which RDS restored

    

    

    

    

    
**Since:** 2.1.0
        


</td></tr>
</tbody></table>



#### ServerlessCapacity



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">min_acus</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the minimum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_acus</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the maximum Aurora capacity unit. Each ACU corresponds to approximately 2 GiB of memory. Must be greater than `min_acus`, if unspecified, the value of `min_acus` will be used.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### StorageConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">allocated_storage</td>
    <td></td>
</tr>
<tr><td colspan="3">

The allocated storage in gibibytes

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the storage type

    
**Allowed Values:**
- `gp3`
- `io1`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_allocated_storage</td>
    <td></td>
</tr>
<tr><td colspan="3">

When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to allocated_storage or `0` to disable Storage Autoscaling

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">provisioned_iops</td>
    <td></td>
</tr>
<tr><td colspan="3">

The amount of provisioned IOPS. Can only be set when `type` is `"io1"` or `"gp3"`. Please refer to [this documentation][rds-provisioned-iops] for more details.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">storage_throughput</td>
    <td></td>
</tr>
<tr><td colspan="3">

The storage throughput value for the DB instance. Can only be set when `type = "gp3"`. Please refer to [this documentation][rds-storage-throughput] for more details.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### TargetGroupConfig

Manages the default target group's configuration

    

    

    

    

    
**Since:** 1.1.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">connection_borrow_timeout</td>
    <td><code>"2 minutes"</code></td>
</tr>
<tr><td colspan="3">

Timeout for borrowing DB connection from the pool. Valid values: `"1 second" - "5 minutes"`

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">connection_pool_maximum_connections</td>
    <td><code>100</code></td>
</tr>
<tr><td colspan="3">

Specify the maximum allowed connections, as a percentage of the maximum connection limit of your database. For example, if you have set the maximum connections to 5,000 connections, specifying `50` allows your proxy to create up to 2,500 connections to the database.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">initalization_query</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify one or more SQL statements to set up the initial session state for each connection. Separate statements with semicolons.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_idle_connections_percent</td>
    <td><code>50</code></td>
</tr>
<tr><td colspan="3">

Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool. For Aurora MySQL, it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster used by the target group.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">session_pinning_filters</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in the list exempts that class of SQL operations from the pinning behavior. This setting is only supported for MySQL engine family databases.

    
**Allowed Values:**
- `EXCLUDE_VARIABLE_SETS`

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
</tbody></table>



#### TargetMetric

The cloudwatch metric to monitor for scaling. Must specify one of the following.

    

    

    

    

    
**Since:** 2.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">average_cpu_utilization_of_aurora_replicas</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The average value of the CPUUtilization metric in CloudWatch across all Aurora Replicas in the Aurora DB cluster.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">average_connections_of_aurora_replicas</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The average value of the DatabaseConnections metric in CloudWatch across all Aurora Replicas in the Aurora DB cluster.

    

    

    

    

    
**Since:** 2.0.0
        


</td></tr>
</tbody></table>




[aurora-capacity-unit]: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html

[aurora-cloudwatch-metrics]: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMonitoring.Metrics.html

[aurora-db-instance-class]: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html

[aurora-failover-priority]: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html#Aurora.Managing.FaultTolerance

[db-instance-class]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html

[manage-password-in-secrets-manager]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html

[rds-ca]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.RegionCertificateAuthorities

[rds-cloudwatch-metrics]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html

[rds-db-encryption]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html

[rds-enhanced-monitoring]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.overview.html

[rds-enhanced-monitoring-iam-requirement]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.Enabling.Prerequisites

[rds-iam-authentication-policy]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html

[rds-iam-db-authentication]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html

[rds-option-group]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html

[rds-performance-insight]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.html

[rds-provisioned-iops]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage

[rds-storage-throughput]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage


<!-- TFDOCS_EXTRAS_END -->

[db-instance-class]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
[rds-ca]:https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.RegionCertificateAuthorities
