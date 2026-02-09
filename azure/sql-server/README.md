# Azure Microsoft SQL Server Module

This module will create and configure an Azure SQL Server and databases.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Requirements](#requirements)
- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Requirements

- Terraform v1.3.0+

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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure">Azure</a>)</code></td>
    <td width="100%">azure</td>
    <td></td>
</tr>
<tr><td colspan="3">

The resource group name and the location where the resources will be deployed to

```terraform
azure = {
resource_group_name = "sandbox"
location = "westus"
}
```

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the SQL server. This value must be globally unique.

    

    

    

    

    
**Since:** 0.0.1
        


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

Additional tags for the SQL server

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>object(<a href="#azureadauthentication">AzureAdAuthentication</a>)</code></td>
    <td width="100%">azure_ad_authentication</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines an Azure AD identity as administrator for this server, can be used with `sql_authentication`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">connection_policy</td>
    <td><code>"Default"</code></td>
</tr>
<tr><td colspan="3">

The connection policy the server will use.

    
**Allowed Values:**
- `Default`
- `Proxy`
- `Redirect`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#databases">Databases</a>))</code></td>
    <td width="100%">databases</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures and manages multiple databases that are attached to this server

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#failovergroups">FailoverGroups</a>))</code></td>
    <td width="100%">failover_groups</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages failover groups for databases failover. In `{failover_group_name = {configurations}}` format. The failover group name must be globally unique.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#firewall">Firewall</a>)</code></td>
    <td width="100%">firewall</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manages firewall rules to allow incoming traffic

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">minimum_tls_version</td>
    <td><code>"1.2"</code></td>
</tr>
<tr><td colspan="3">

The minimum TLS version for all SQL Database and SQL Data Warehouse databases associated with the server.

    
**Allowed Values:**
- `1.0`
- `1.1`
- `1.2`
- `Disabled`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">outbound_network_restriction_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether outbound network traffic is restricted for this server

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">public_network_access_enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether public network access is allowed for this server

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">server_version</td>
    <td><code>"12.0"</code></td>
</tr>
<tr><td colspan="3">

The version for the SQL server.

- `2.0` for v11 server
- `12.0` for v12 server

    
**Allowed Values:**
- `2.0`
- `12.0`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>object(<a href="#sqlauthentication">SqlAuthentication</a>)</code></td>
    <td width="100%">sql_authentication</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines the administrator login credential for this SQL server, can be used with `azure_ad_authentication`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">user_assigned_managed_identity_ids</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of managed identity IDs used by the SQL server to manage Azure resources

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        </tbody></table>

## Objects



#### Azure



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the server will be deployed

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the server will be deployed. If unspecified, the resource group's location will be used.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### AzureAdAuthentication



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">object_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The object ID of an Azure AD identity (user, group)

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">tenant_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The tenant ID for the domain where the identity lives

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### Databases



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the database

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">backup_storage_redundancy</td>
    <td><code>"Geo"</code></td>
</tr>
<tr><td colspan="3">

Specifies the storage account type used to store backups for this database.

    
**Allowed Values:**
- `Geo`
- `Local`
- `Zone`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">bring_your_own_license</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Use your license you already own with Azure Hybrid Benefit

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">collation</td>
    <td><code>"SQL_Latin1_General_CP1_CI_AS"</code></td>
</tr>
<tr><td colspan="3">

Database collation defines the rules that sort and compare data, and cannot be changed after database creation

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">create_mode</td>
    <td><code>"Default"</code></td>
</tr>
<tr><td colspan="3">

Defines the create action of the database.

    
**Allowed Values:**
- `Copy`
- `Default`
- `OnlineSecondary`
- `PointInTimeRestore`
- `Recovery`
- `Restore`
- `RestoreExternalBackup`
- `RestoreExternalBackupSecondary`
- `RestoreLongTermRetentionBackup`
- `Secondary`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">data_max_size</td>
    <td><code>2</code></td>
</tr>
<tr><td colspan="3">

The max size of the database in gigabytes.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>object(<a href="#dtumodel">DtuModel</a>)</code></td>
    <td width="100%">dtu_model</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the database using the DTU pricing model

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>object(<a href="#vcoremodel">VcoreModel</a>)</code></td>
    <td width="100%">vcore_model</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the database using the VCore pricing model

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">ledger_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Specifies if this is a ledger database; cannot be changed after database creation

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">read_scale_out_enabled</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property can only be set in `Premium` and `BusinessCritical` tiers.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">restore_point_in_time</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property can only be set in `create_mode = "PointInTimeRestore"` databases.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">source_database_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ID of the source database from which to create the new database. This should only be used for databases with create_mode values that use another database as reference. Changing this forces a new resource to be created.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">zone_redundant</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property can only be set in `Premium` and `BusinessCritical` tiers.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### DtuModel

Configures the database using the DTU pricing model

    

    

    

    

    
**Since:** 0.0.1
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">tier</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the tier of this database. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

    
**Allowed Values:**
- `Basic`
- `Standard`
- `Premium`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">dtu</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Defines the number of DTU for the database. Please run the above command to get a list of DTU applicable to your region.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### FailoverGroups



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">databases</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of database names to be included in this failover group. The names supplied here must be databases deployed using the same module.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">secondary_server_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the ID of the MS SQL server to failover to. This server **must** exist in a different region.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for this failover group

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">read_write_failover_policy</td>
    <td><code>"Automatic"</code></td>
</tr>
<tr><td colspan="3">

Defines the failover policy of the read-write endpoint for the failover group.

    
**Allowed Values:**
- `Automatic`
- `Manual`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">read_write_grace_period_minutes</td>
    <td><code>60</code></td>
</tr>
<tr><td colspan="3">

The grace period in minutes, before failover with data loss is attempted for the read-write endpoint. Required when `read_write_failover_policy = "Automatic"`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Firewall



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">rules</td>
    <td></td>
</tr>
<tr><td colspan="3">

A map of firewall rules in the following format: `{"rule_name" = "start_ip - end_ip"}`. For example. `{"Office's Network" = "1.2.3.4 - 5.6.7.8"}`. If `start_ip` and `end_ip` are identical, you can omit `end_ip`. For example. `{"Peter's home network" = "1.2.3.4"}`

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_access_to_azure_services</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Allows Azure services to access the database

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### SqlAuthentication



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">admin_username</td>
    <td></td>
</tr>
<tr><td colspan="3">

Username of the admin account

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">admin_password</td>
    <td></td>
</tr>
<tr><td colspan="3">

Password of the admin account in plain text

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>



#### VcoreModel

Configures the database using the VCore pricing model

    

    

    

    

    
**Since:** 0.0.1
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">tier</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the tier of this database. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

    
**Allowed Values:**
- `GeneralPurpose`
- `Hyperscale`
- `BusinessCritical`
- `Serverless`

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">vcores</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the number of VCores for the database. Please run the above command to get a list of VCores options applicable to your region.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">auto_pause_delay_in_minutes</td>
    <td><code>-1</code></td>
</tr>
<tr><td colspan="3">

Time in minutes after which database is automatically paused. A value of `-1` means that automatic pause is disabled. This property is only applicable to the `Serverless` tier

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">compute</td>
    <td><code>"Gen5"</code></td>
</tr>
<tr><td colspan="3">

Defines the compute for the database. Note that certain compute options are only available to certain tiers, and may not be available in some regions. Run this CLI command to get a list of options applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">min_vcores</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

Minimum capacity that database will always have allocated, if not paused. This property is only applicable to the `Serverless` tier.

    

    

    

    

    
**Since:** 0.0.1
        


</td></tr>
</tbody></table>





<!-- TFDOCS_EXTRAS_END -->
