variable "azure" {
  type = object({
    /// The name of an Azure resource group where the server will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the server will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location = optional(string, null)
  })

  description = <<EOT
    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    @since 0.0.1
  EOT
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the SQL server. This value must be globally unique.

    @since 0.0.1
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the SQL server

    @since 0.0.1
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 0.0.1
  EOT
  default     = {}
}

variable "azure_ad_authentication" {
  type = object({
    /// The object ID of an Azure AD identity (user, group)
    ///
    /// @since 0.0.1
    object_id = string
    /// The tenant ID for the domain where the identity lives
    ///
    /// @since 0.0.1
    tenant_id = optional(string, null)
  })

  description = <<EOT
    Defines an Azure AD identity as administrator for this server, can be used with `sql_authentication`

    @since 0.0.1
  EOT
  default     = null
}

variable "connection_policy" {
  type        = string
  description = <<EOT
    The connection policy the server will use.

    @enum Default|Proxy|Redirect
    @since 0.0.1
  EOT
  default     = "Default"
}

variable "databases" {
  type = map(object({
    /// Additional tags for the database
    ///
    /// @since 0.0.1
    additional_tags = optional(map(string), {})
    /// Specifies the storage account type used to store backups for this database.
    ///
    /// @enum Geo|Local|Zone
    /// @since 0.0.1
    backup_storage_redundancy = optional(string, "Geo")
    /// Use your license you already own with Azure Hybrid Benefit
    ///
    /// @since 0.0.1
    bring_your_own_license = optional(bool, false)
    /// Database collation defines the rules that sort and compare data, and cannot be changed after database creation
    ///
    /// @since 0.0.1
    collation = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    /// Defines the create action of the database.
    ///
    /// @enum Copy|Default|OnlineSecondary|PointInTimeRestore|Recovery|Restore|RestoreExternalBackup|RestoreExternalBackupSecondary|RestoreLongTermRetentionBackup|Secondary
    /// @since 0.0.1
    create_mode = optional(string, "Default")
    /// The max size of the database in gigabytes.
    ///
    /// @since 0.0.1
    data_max_size = optional(number, 2)

    /// Configures the database using the DTU pricing model
    ///
    /// @since 0.0.1
    dtu_model = optional(object({
      /// Defines the tier of this database. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.
      ///
      /// @enum Basic|Standard|Premium
      /// @since 0.0.1
      tier = string # Basic, Standard, Premium
      /// Defines the number of DTU for the database. Please run the above command to get a list of DTU applicable to your region.
      ///
      /// @since 0.0.1
      dtu = optional(number, null)
    }))

    /// Configures the database using the VCore pricing model
    ///
    /// @since 0.0.1
    vcore_model = optional(object({
      /// Defines the tier of this database. Note that some tiers are not available for some regions. Run this CLI command to get a list of tiers applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.
      ///
      /// @enum GeneralPurpose|Hyperscale|BusinessCritical|Serverless
      /// @since 0.0.1
      tier = string # GeneralPurpose, Hyperscale, Serverless
      /// Defines the number of VCores for the database. Please run the above command to get a list of VCores options applicable to your region.
      ///
      /// @since 0.0.1
      vcores = number
      /// Time in minutes after which database is automatically paused. A value of `-1` means that automatic pause is disabled. This property is only applicable to the `Serverless` tier
      ///
      /// @since 0.0.1
      auto_pause_delay_in_minutes = optional(number, -1)
      /// Defines the compute for the database. Note that certain compute options are only available to certain tiers, and may not be available in some regions. Run this CLI command to get a list of options applicable to your region. `az sql db list-editions --location westus --output table`. Where `--location` should be set to your region.
      ///
      /// @since 0.0.1
      compute = optional(string, "Gen5")
      /// Minimum capacity that database will always have allocated, if not paused. This property is only applicable to the `Serverless` tier.
      ///
      /// @since 0.0.1
      min_vcores = optional(number, 1)
    }))

    /// Specifies if this is a ledger database; cannot be changed after database creation
    ///
    /// @since 0.0.1
    ledger_enabled = optional(bool, false)
    /// If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property can only be set in `Premium` and `BusinessCritical` tiers.
    ///
    /// @since 0.0.1
    read_scale_out_enabled = optional(bool, null)
    /// Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property can only be set in `create_mode = "PointInTimeRestore"` databases.
    ///
    /// @since 0.0.1
    restore_point_in_time = optional(string, null)
    /// The ID of the source database from which to create the new database. This should only be used for databases with create_mode values that use another database as reference. Changing this forces a new resource to be created.
    ///
    /// @since 0.0.1
    source_database_id = optional(string, null)
    /// Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property can only be set in `Premium` and `BusinessCritical` tiers.
    ///
    /// @since 0.0.1
    zone_redundant = optional(bool, false)
  }))

  description = <<EOT
    Configures and manages multiple databases that are attached to this server

    @since 0.0.1
  EOT
  default     = {}
}

variable "failover_groups" {
  type = map(object({
    /// A list of database names to be included in this failover group. The names supplied here must be databases deployed using the same module.
    ///
    /// @example "Basic Usage" #basic-usage
    /// @since 1.0.0
    databases = list(string)
    /// Defines the ID of the MS SQL server to failover to. This server **must** exist in a different region.
    ///
    /// @since 1.0.0
    secondary_server_id = string
    /// Additional tags for this failover group
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})
    /// Defines the failover policy of the read-write endpoint for the failover group.
    ///
    /// @enum Automatic|Manual
    /// @since 1.0.0
    read_write_failover_policy = optional(string, "Automatic")
    /// The grace period in minutes, before failover with data loss is attempted for the read-write endpoint. Required when `read_write_failover_policy = "Automatic"`
    ///
    /// @since 1.0.0
    read_write_grace_period_minutes = optional(number, 60)
  }))

  description = <<EOT
    Manages failover groups for databases failover. In `{failover_group_name = {configurations}}` format. The failover group name must be globally unique.

    @since 1.0.0
  EOT
  default     = {}
}

variable "firewall" {
  type = object({
    /// A map of firewall rules in the following format: `{"rule_name" = "start_ip - end_ip"}`. For example. `{"Office's Network" = "1.2.3.4 - 5.6.7.8"}`. If `start_ip` and `end_ip` are identical, you can omit `end_ip`. For example. `{"Peter's home network" = "1.2.3.4"}`
    ///
    /// @since 0.0.1
    rules = map(string)
    /// Allows Azure services to access the database
    ///
    /// @since 0.0.1
    allow_access_to_azure_services = optional(bool, false)
  })

  description = <<EOT
    Manages firewall rules to allow incoming traffic

    @since 0.0.1
  EOT
  default     = null
}

variable "minimum_tls_version" {
  type        = string
  description = <<EOT
    The minimum TLS version for all SQL Database and SQL Data Warehouse databases associated with the server.

    @enum 1.0|1.1|1.2|Disabled
    @since 0.0.1
  EOT
  default     = "1.2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = <<EOT
    Whether public network access is allowed for this server

    @since 0.0.1
  EOT
  default     = true
}

variable "outbound_network_restriction_enabled" {
  type        = bool
  description = <<EOT
    Whether outbound network traffic is restricted for this server

    @since 0.0.1
  EOT
  default     = false
}

variable "sql_authentication" {
  type = object({
    /// Username of the admin account
    ///
    /// @since 0.0.1
    admin_username = string
    /// Password of the admin account in plain text
    ///
    /// @since 0.0.1
    admin_password = string
  })

  description = <<EOT
    Defines the administrator login credential for this SQL server, can be used with `azure_ad_authentication`

    @since 0.0.1
  EOT
  default     = null
}

variable "user_assigned_managed_identity_ids" {
  type        = list(string)
  description = <<EOT
    List of managed identity IDs used by the SQL server to manage Azure resources

    @since 0.0.1
  EOT
  default     = []
}

variable "server_version" {
  type        = string
  description = <<EOT
    The version for the SQL server.

    - `2.0` for v11 server
    - `12.0` for v12 server

    @enum 2.0|12.0
    @since 0.0.1
  EOT
  default     = "12.0"
}
