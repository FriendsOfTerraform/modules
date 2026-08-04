# Automation Account Module

This module will create and configure an [Azure Automation Account][azure-automation-account] and manages related resources such as Runbooks and Schedules

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Runbooks](#runbooks)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#azure">azure</a>)</code></td>
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

The name of the automation account

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

Additional tags for the automation account

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
    <td><code>map(object(<a href="#runbooks">runbooks</a>))</code></td>
    <td width="100%">runbooks</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

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

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">user_assigned_managed_identity_ids</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of managed identity IDs used by the automation account to manage azure resources

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>list(object)</code></td>
    <td width="100%">automation_account_identity</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of identities attached to the automation account

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">runbook_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of runbook IDs

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">schedule_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of schedule IDs

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Objects

#### azure

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the automation account will be deployed

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the automation account will be deployed. If unspecified, the resource group's location will be used.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### daily

Defines a daily schedule

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">interval</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines how many days per schedule trigger

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### hourly

Defines a hourly schedule

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">interval</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines how many hours per schedule trigger

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### monthly

Defines a monthly schedule

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">interval</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines how many months per schedule trigger

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">every</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines one of the following:

- A list of days in the month this schedule should run. Valid values are `numbers between "1" and "31", and "-1" (representing last day of the month)`. Example: `["1", "5", "20", "-1"]` means 1st, 5th, 20th, and the last day of the month.
- The `[{week}, {day_of_week}]` this schedule should run. Valid values are: {week}: `"First", "Second", "Third", "Fourth", "Last"`. {day_of_week}: `"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"`. Example: `["First", "Thursday"]`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### runbooks

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">content</td>
    <td></td>
</tr>
<tr><td colspan="3">

The content of the runbook. This can either be the actual script itself, or a `uri` referencing the content remotely.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td></td>
</tr>
<tr><td colspan="3">

Additional tags for the runbook

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Description of the runbook

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">log_progress</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables logging the progress of the runbook

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">log_verbose</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables verbose logging

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">runbook_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the type of the runbook.

**Allowed Values:**

- `Graph`
- `GraphPowerShell`
- `GraphPowerShellWorkflow`
- `PowerShellWorkflow`
- `PowerShell`
- `Script`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#schedule">schedule</a>)</code></td>
    <td width="100%">schedule</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines schedule to automatically trigger this runbook

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### schedule

Defines schedule to automatically trigger this runbook

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Description of the schedule

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">timezone</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the timezone this runbook schedules on. Refer to [this list][azure-timezones] for valid timezones.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">start_time</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the start time of the schedule, in [RFC3339 DateTime format][rfc3339]. Defaults to `current time + 7 minutes`.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">expiry_time</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the expiry time of the schedule, in [RFC3339 DateTime format][rfc3339].

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">parameters</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a map of parameters to be passed into the runbook when this schedule runs

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#hourly">hourly</a>)</code></td>
    <td width="100%">hourly</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a hourly schedule

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#daily">daily</a>)</code></td>
    <td width="100%">daily</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a daily schedule

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#weekly">weekly</a>)</code></td>
    <td width="100%">weekly</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a weekly schedule

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#monthly">monthly</a>)</code></td>
    <td width="100%">monthly</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a monthly schedule

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### weekly

Defines a weekly schedule

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">interval</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines how many weeks per schedule trigger

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">every</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines the days of the week this schedule should run on.

**Allowed Values:**

- `Monday`
- `Tuesday`
- `Wednesday`
- `Thursday`
- `Friday`
- `Saturday`
- `Sunday`

**Since:** 0.0.1

</td></tr>
</tbody></table>

[azure-timezones]: https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/timezone
[rfc3339]: https://medium.com/easyread/understanding-about-rfc-3339-for-datetime-formatting-in-software-engineering-940aa5d5f68a

<!-- TFDOCS_EXTRAS_END -->

[azure-automation-account]: https://docs.microsoft.com/en-us/azure/automation/overview
