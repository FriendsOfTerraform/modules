# Automation Account Module

This module will create and configure an [Azure Automation Account][azure-automation-account] and manages related resources such as Runbooks and Schedules

## Table of Contents

- [Example Usage](#example-usage)
    - [Runbooks](#runbooks)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Runbooks

This example creates an automation account name `demo-automation-account` and then multiple runbooks scheduled using different frequencies.

```terraform
module "automation" {
  source = "github.com/FriendsOfTerraform/azure-automation.git?ref=v0.0.1"

  azure = { resource_group_name = "sandbox" }
  name  = "demo-automation-account"

  runbooks = {
    "one_time" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run only once at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
      }
    }

    "hourly" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run once every hour at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
        hourly     = { interval = 1 }
      }
    }

    "daily" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run once a day at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
        daily      = { interval = 1 }
      }
    }

    "weekly" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run every one week every Saturday and Sunday at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
        weekly = {
          interval = 1
          every    = ["Saturday", "Sunday"]
        }
      }
    }

    "montly_week" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run every one month at the Second Tuesday at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
        monthly = {
          interval = 1
          every    = ["Second", "Tuesday"]
        }
      }
    }

    "montly_days" = {
      content = <<-EOT
        Write-Host "Hello World"  
      EOT

      # Run every one month at the 1st, 10th, and last day at 2300 PST
      schedule = {
        timezone   = "America/Los_Angeles"
        start_time = "2022-09-04T23:00:00.000-07:00"
        monthly = {
          interval = 1
          every    = ["1", "10", "-1"]
        }
      }
    }
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

        The name of an Azure resource group where the automation account will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the automation account will be deployed. If unspecified, the resource group's location will be used.

- (string) **`name`** _[since v0.0.1]_

    The name of the automation account

### Optional

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the automation account

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (map(object)) **`runbooks = {}`** _[since v0.0.1]_

    Defines and manages multiple runbooks and their schedules

    ```terraform
    runbooks = {
      "hourly" = {
        content = <<-EOT
          Write-Host "Hello World"  
        EOT
  
        # Run once every hour at 2300 PST
        schedule = {
          timezone   = "America/Los_Angeles"
          start_time = "2022-09-04T23:00:00.000-07:00"
          hourly     = { interval = 1 }
        }
      }
    }
    ```

    - (string) **`content`** _[since v0.0.1]_

        The content of the runbook. This can either be the actual script itself, or a `uri` referencing the content remotely.

    - (map(string)) **`additional_tags`** _[since v0.0.1]_

        Additional tags for the runbook

    - (string) **`description = null`** _[since v0.0.1]_

        Description of the runbook

    - (bool) **`log_progress = true`** _[since v0.0.1]_

        Enables logging the progress of the runbook

    - (bool) **`log_verbose = false`** _[since v0.0.1]_

        Enables verbose logging

    - (string) **`runbook_type = "PowerShell"`** _[since v0.0.1]_

        Defines the type of the runbook. Valid values are: `"Graph", "GraphPowerShell", "GraphPowerShellWorkflow", "PowerShellWorkflow", "PowerShell", or "Script"`

    - (object) **`schedule = null`** _[since v0.0.1]_

        Defines schedule to automatically trigger this runbook

        - (string) **`description = null`** _[since v0.0.1]_

            Description of the schedule

        - (string) **`timezone = "UTC"`** _[since v0.0.1]_

            Defines the timezone this runbook schedules on. Refer to [this list][azure-timezones] for valid timezones.

        - (string) **`start_time = null`** _[since v0.0.1]_

            Defines the start time of the schedule, in [RFC3339 DateTime format][rfc3339]. Defaults to `current time + 7 minutes`.

        - (string) **`expiry_time = null`** _[since v0.0.1]_

            Defines the expiry time of the schedule, in [RFC3339 DateTime format][rfc3339].

        - (map(string)) **`parameters = null`** _[since v0.0.1]_

            Defines a map of parameters to be passed into the runbook when this schedule runs

        - (object) **`hourly = null`** _[since v0.0.1]_

            Defines a hourly schedule

            - (number) **`interval = 1`** _[since v0.0.1]_

                Defines how many hours per schedule trigger

        - (object) **`daily = null`** _[since v0.0.1]_

            Defines a daily schedule

            - (number) **`interval = 1`** _[since v0.0.1]_

                Defines how many days per schedule trigger

        - (object) **`weekly = null`** _[since v0.0.1]_

            Defines a weekly schedule

            - (list(string)) **`every`** _[since v0.0.1]_

                Defines the days of the week this schedule should run on. Valid values are: `"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"`
                
            - (number) **`interval = 1`** _[since v0.0.1]_

                Defines how many weeks per schedule trigger

        - (object) **`monthly = null`** _[since v0.0.1]_

            Defines a monthly schedule

            - (list(string)) **`every`** _[since v0.0.1]_

                Defines one of the following: 
                
                - A list of days in the month this schedule should run. Valid values are `numbers between "1" and "31", and "-1" (representing last day of the month)`. Example: `["1", "5", "20", "-1"]` means 1st, 5th, 20th, and the last day of the month.

                - The `[{week}, {day_of_week}]` this schedule should run. Valid values are: {week}: `"First", "Second", "Third", "Fourth", "Last"`. {day_of_week}: `"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"`. Example: `["First", "Thursday"]`
                
            - (number) **`interval = 1`** _[since v0.0.1]_

                Defines how many months per schedule trigger

    - (list(string)) **`user_assigned_managed_identity_ids = []`** _[since v0.0.1]_

        List of managed identity IDs used by the automation account to manage azure resources

## Outputs

- (list(object)) **`automation_account_identity`** _[since v0.0.1]_

    List of identities attached to the automation account

- (map(string)) **`runbook_ids`** _[since v0.0.1]_

    List of runbook IDs
    
- (map(string)) **`schedule_ids`** _[since v0.0.1]_

    List of schedule IDs
                
[azure-automation-account]:https://docs.microsoft.com/en-us/azure/automation/overview
[azure-timezones]:https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/timezone
[rfc3339]:https://medium.com/easyread/understanding-about-rfc-3339-for-datetime-formatting-in-software-engineering-940aa5d5f68a