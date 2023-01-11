# Azure Microsoft SQL Server Module

This module will create and configure an Azure SQL Server and databases.

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

This example creates an Azure MS SQL server using Azure AD authentication, then it creates two databases with different pricing models. After that, it demonstrates how to configure the firewall to allow incoming traffic.

```terraform
module "mssql" {
  source = "github.com/FriendsOfTerraform/azure-sql-server.git?ref=v1.0.0"

  azure = {
    resource_group_name = "demo"
  }

  name = "petersin-mssql"

  azure_ad_authentication = {
    object_id = "3b170aa6-ac36-472a-xxxx-xxxxxx-xxxxxxx"
  }

  databases = {
    "demo-dtu" = {
      dtu_model = {
        tier = "Standard"
        dtu  = 20
      }
    }

    "demo-vcore" = {
      vcore_model = {
        tier    = "GeneralPurpose"
        vcores  = 10
        compute = "Gen5"
      }
    }
  }

  failover_groups = {
    demo-failover-group = {
      # The database names supplied here must be the same ones created within the same declaration
      databases = [
        "demo-dtu",
        "demo-vcore"
      ]

      secondary_server_id = "/subscriptions/1528e238-333b-xxxx-xxxx-xxxxxxxxxx/resourceGroups/demo/providers/Microsoft.Sql/servers/petersin-secondary-mssql"
    }
  }

  firewall = {
    rules = {
      # You can omit the ending IP address if it is the same as the starting IP address
      "Brian's Home"       = "10.11.12.13"
      "Stewie's Home"      = "9.10.11.12"
      "Primary Datacenter" = "130.166.0.0 - 130.166.255.255"
    }

    allow_access_to_azure_services = true
  }
}  
```

## Argument Reference

### Mandatory

- (object) **`azure`** _[since v0.0.1]_

    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    - (string) **`resource_group_name`** _[since v0.0.1]_

        The name of an Azure resource group where the server will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the server will be deployed. If unspecified, the resource group's location will be used.

- (string) **`name`** _[since v0.0.1]_

    The name of the SQL server. This value must be globally unique.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the SQL server

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (object) **`azure_ad_authentication = null`** _[since v0.0.1]_

    Defines an Azure AD identity as administrator for this server, can be used with `sql_authentication`

    - (string) **`object_id`** _[since v0.0.1]_

        The object ID of an Azure AD identity (user, group)

    - (string) **`tenant_id = null`** _[since v0.0.1]_

        The tenant ID for the domain where the identity lives

- (string) **`connection_policy = "Default"`** _[since v0.0.1]_

    The connection policy the server will use. Possible values are `Default`, `Proxy`, and `Redirect`

- (map(object)) **`databases = {}`** _[since v0.0.1]_

    Configures and manages multiple databases that are attached to this server

    - (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

        Additional tags for the database

    - (string) **`backup_storage_redundancy = "Geo"`** _[since v0.0.1]_

        Specifies the storage account type used to store backups for this database. Possible values are `Geo`, `Local` and `Zone`

    - (bool) **`bring_your_own_license = false`** _[since v0.0.1]_

        Use your license you already own with Azure Hybrid Benefit

    - (string) **`collation = "SQL_Latin1_General_CP1_CI_AS"`** _[since v0.0.1]_

        Database collation defines the rules that sort and compare data, and cannot be changed after database creation

    - (string) **`create_mode = "Default"`** _[since v0.0.1]_

        Defines the create action of the database. Possible values are `Copy`, `Default`, `OnlineSecondary`, `PointInTimeRestore`, `Recovery`, `Restore`, `RestoreExternalBackup`, `RestoreExternalBackupSecondary`, `RestoreLongTermRetentionBackup` and `Secondary`

    - (number) **`data_max_size = 2`** _[since v0.0.1]_

        The max size of the database in gigabytes.        

    - (object) **`dtu_model = null`** _[since v0.0.1]_

        Configures the database using the DTU pricing model

        - (string) **`tier`** _[since v0.0.1]_

            Defines the tier of this database. Possible values are `Basic`, `Standard`, and `Premium`. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

        - (number) **`dtu = null`** _[since v0.0.1]_

            Defines the number of DTU for the database. Please run the above command to get a list of DTU applicable to your region.

    - (object) **`vcore_model = null`** _[since v0.0.1]_

        Configures the database using the VCore pricing model

        - (string) **`tier`** _[since v0.0.1]_

            Defines the tier of this database. Possible values are `GeneralPurpose`, `Hyperscale`, `BusinessCritical`, and `Serverless`. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

        - (number) **`vcores`** _[since v0.0.1]_

            Defines the number of VCores for the database. Please run the above command to get a list of VCores options applicable to your region.

        - (number) **`auto_pause_delay_in_minutes = -1`** _[since v0.0.1]_

            Time in minutes after which database is automatically paused. A value of `-1` means that automatic pause is disabled. This property is only applicable to the `Serverless` tier

        - (string) **`compute = "Gen5"`** _[since v0.0.1]_

            Defines the compute for the database. Note that certain compute options are only available to certain tiers, and may not be available in some regions. Run this CLI command to get a list of options applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

        - (number) **`min_vcores = 1`** _[since v0.0.1]_

            Minimum capacity that database will always have allocated, if not paused. This property is only applicable to the `Serverless` tier.

    - (bool) **`ledger_enabled = false`** _[since v0.0.1]_

        Specifies if this is a ledger database; cannot be changed after database creation

    - (bool) **`read_scale_out_enabled = null`** _[since v0.0.1]_

        If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property can only be set in `Premium` and `BusinessCritical` tiers.

    - (string) **`restore_point_in_time = null`** _[since v0.0.1]_

        Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property can only be set in `create_mode = "PointInTimeRestore"` databases.

    - (string) **`source_database_id = null`** _[since v0.0.1]_

        The ID of the source database from which to create the new database. This should only be used for databases with create_mode values that use another database as reference. Changing this forces a new resource to be created.

    - (bool) **`zone_redundant = false`** _[since v0.0.1]_

        Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property can only be set in `Premium` and `BusinessCritical` tiers.

- (map(object)) **`failover_groups = {}`** _[since v1.0.0]_

    Manages failover groups for databases failover. In `{failover_group_name = {configurations}}` format. The failover group name must be globally unique.

    - (list(string)) **`databases`** _[since v1.0.0]_

        A list of database names to be included in this failover group. The names supplied here must be databases deployed using the same module. Please see [Basic Usage](#basic-usage) for an example.

    - (string) **`secondary_server_id`** _[since v1.0.0]_

        Defines the ID of the MS SQL server to failover to. This server must exists in a different region.

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for this failover group

    - (string) **`read_write_failover_policy = "Automatic"`** _[since v1.0.0]_

        Defines the failover policy of the read-write endpoint for the failover group. Possible values are `"Automatic"` or `"Manual"`

    - (number) **`read_write_grace_period_minutes = 60`** _[since v1.0.0]_

        The grace period in minutes, before failover with data loss is attempted for the read-write endpoint. Required when `read_write_failover_policy = "Automatic"`

- (object) **`firewall = null`** _[since v0.0.1]_

    Manages firewall rules to allow incoming traffic

    - (map(string)) **`rules`** _[since v0.0.1]_

        A map of firewall rules in the following format: `{"rule_name" = "start_ip - end_ip"}`. For example. `{"Office's Network" = "1.2.3.4 - 5.6.7.8"}`. If `start_ip` and `end_ip` are identical, you can omit `end_ip`. For example. `{"Peter's home network" = "1.2.3.4"}`

    - (bool) **`allow_access_to_azure_services = false`** _[since v0.0.1]_

        Allows Azure services to access the database

- (string) **`minimum_tls_version = "1.2"`** _[since v0.0.1]_

    The minimum TLS version for all SQL Database and SQL Data Warehouse databases associated with the server. Valid values are: `1.0`, `1.1`, `1.2` and `Disabled`

- (bool) **`public_network_access_enabled = true`** _[since v0.0.1]_

    Whether public network access is allowed for this server

- (bool) **`outbound_network_restriction_enabled = false`** _[since v0.0.1]_

    Whether outbound network traffic is restricted for this server

- (object) **`sql_authentication = null`** _[since v0.0.1]_

    Defines the administrator login credential for this SQL server, can be used with `azure_ad_authentication`

    - (string) **`admin_username`** _[since v0.0.1]_

        Username of the admin account

    - (string) **`admin_password`** _[since v0.0.1]_

        Password of the admin account in plain text

- (list(string)) **`user_assigned_managed_identity_ids = []`** _[since v0.0.1]_

    List of managed identity IDs used by the SQL server to manage Azure resources

- (string) **`server_version = "12.0"`** _[since v0.0.1]_

    The version for the SQL server. Valid values are: `2.0` (for v11 server) and `12.0` (for v12 server)
