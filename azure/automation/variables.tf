variable "azure" {
  type = object({
    /// The name of an Azure resource group where the automation account will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string
    /// The name of an Azure location where the automation account will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location = optional(string)
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
    The name of the automation account

    @since 0.0.1
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the automation account

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

variable "runbooks" {
  type = map(object({
    /// The content of the runbook. This can either be the actual script itself, or a `uri` referencing the content remotely.
    ///
    /// @since 0.0.1
    content = string
    /// Additional tags for the runbook
    ///
    /// @since 0.0.1
    additional_tags = optional(map(string))
    /// Description of the runbook
    ///
    /// @since 0.0.1
    description = optional(string)
    /// Enables logging the progress of the runbook
    ///
    /// @since 0.0.1
    log_progress = optional(bool)
    /// Enables verbose logging
    ///
    /// @since 0.0.1
    log_verbose = optional(bool)
    /// Defines the type of the runbook.
    ///
    /// @enum Graph|GraphPowerShell|GraphPowerShellWorkflow|PowerShellWorkflow|PowerShell|Script
    /// @since 0.0.1
    runbook_type = optional(string)

    /// Defines schedule to automatically trigger this runbook
    ///
    /// @since 0.0.1
    schedule = optional(object({
      /// Description of the schedule
      ///
      /// @since 0.0.1
      description = optional(string)
      /// Defines the timezone this runbook schedules on. Refer to [this list][azure-timezones] for valid timezones.
      ///
      /// @link {azure-timezones} https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/timezone
      /// @since 0.0.1
      timezone = optional(string)
      /// Defines the start time of the schedule, in [RFC3339 DateTime format][rfc3339]. Defaults to `current time + 7 minutes`.
      ///
      /// @link {rfc3339} https://medium.com/easyread/understanding-about-rfc-3339-for-datetime-formatting-in-software-engineering-940aa5d5f68a
      /// @since 0.0.1
      start_time = optional(string)
      /// Defines the expiry time of the schedule, in [RFC3339 DateTime format][rfc3339].
      ///
      /// @link {rfc3339} https://medium.com/easyread/understanding-about-rfc-3339-for-datetime-formatting-in-software-engineering-940aa5d5f68a
      /// @since 0.0.1
      expiry_time = optional(string)
      /// Defines a map of parameters to be passed into the runbook when this schedule runs
      ///
      /// @since 0.0.1
      parameters = optional(map(string))

      /// Defines a hourly schedule
      ///
      /// @since 0.0.1
      hourly = optional(object({
        /// Defines how many hours per schedule trigger
        ///
        /// @since 0.0.1
        interval = optional(number)
      }))

      /// Defines a daily schedule
      ///
      /// @since 0.0.1
      daily = optional(object({
        /// Defines how many days per schedule trigger
        ///
        /// @since 0.0.1
        interval = optional(number)
      }))

      /// Defines a weekly schedule
      ///
      /// @since 0.0.1
      weekly = optional(object({
        /// Defines how many weeks per schedule trigger
        ///
        /// @since 0.0.1
        interval = optional(number)
        /// Defines the days of the week this schedule should run on.
        ///
        /// @enum Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday
        /// @since 0.0.1
        every = list(string)
      }))

      /// Defines a monthly schedule
      ///
      /// @since 0.0.1
      monthly = optional(object({
        /// Defines how many months per schedule trigger
        ///
        /// @since 0.0.1
        interval = optional(number)
        /// Defines one of the following:
        ///
        /// - A list of days in the month this schedule should run. Valid values are `numbers between "1" and "31", and "-1" (representing last day of the month)`. Example: `["1", "5", "20", "-1"]` means 1st, 5th, 20th, and the last day of the month.
        /// - The `[{week}, {day_of_week}]` this schedule should run. Valid values are: {week}: `"First", "Second", "Third", "Fourth", "Last"`. {day_of_week}: `"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"`. Example: `["First", "Thursday"]`
        ///
        /// @since 0.0.1
        every = list(string)
      }))
    }))
  }))

  description = <<EOT
    Defines and manages multiple runbooks and their schedules

    ```terraform
    runbooks = {
      "hourly" = {
        content = "Write-Host 'Hello World'"

        # Run once every hour at 2300 PST
        schedule = {
          timezone   = "America/Los_Angeles"
          start_time = "2022-09-04T23:00:00.000-07:00"
          hourly     = { interval = 1 }
        }
      }
    }
    ```

    @since 0.0.1
  EOT
  default     = {}
}

variable "user_assigned_managed_identity_ids" {
  type        = list(string)
  description = <<EOT
    List of managed identity IDs used by the automation account to manage azure resources

    @since 0.0.1
  EOT
  default     = []
}
