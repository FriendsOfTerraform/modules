variable "name" {
  type        = string
  description = <<EOT
    Name of the Azure DevOps Pipeline to create.

    @since 1.0.0
  EOT
}

variable "project_name" {
  type        = string
  description = <<EOT
    Name of the existing Azure DevOps project that owns the pipeline.
    Resolved by the shared project data source; this module does not create it.

    @since 1.0.0
  EOT
}

variable "yaml_source" {
  type = object({
    /// Existing Azure Repos Git repository in the pipeline's project.
    ///
    /// @since 1.0.0
    azure_repo_git = optional(object({
      /// Repository name, resolved within project_name.
      ///
      /// @since 1.0.0
      repository = string
      /// Source branch as a short name or refs/heads/ ref.
      ///
      /// @since 1.0.0
      branch = string
      /// Path to the pipeline YAML file in the repository.
      ///
      /// @since 1.0.0
      path = string
    }), null)
  })
  nullable    = false
  description = <<EOT
    Pipeline source configuration. Currently azure_repo_git is required and
    refers to an existing repository in project_name. Set repository to its
    name, branch to the source branch (short name or refs/heads/ ref), and path
    to the YAML file path in that repository. All values must be nonblank.

    @since 1.0.0
  EOT

  validation {
    condition = var.yaml_source.azure_repo_git == null ? false : alltrue([
      for value in [
        var.yaml_source.azure_repo_git.repository,
        var.yaml_source.azure_repo_git.branch,
        var.yaml_source.azure_repo_git.path
      ] : value == null ? false : length(trimspace(value)) > 0 && value == trimspace(value)
    ])
    error_message = "yaml_source.azure_repo_git is required; its repository, branch, and path must be non-empty strings without surrounding whitespace."
  }
}

variable "status" {
  type        = string
  description = <<EOT
    Whether the pipeline is enabled. Defaults to "enabled"; "disabled" disables it; "paused" pauses it.

    @since 1.0.0
  EOT
  default     = "enabled"

  validation {
    condition     = var.status == null ? false : contains(["enabled", "disabled", "paused"], var.status)
    error_message = "status must be one of: enabled, disabled, or paused."
  }
}

variable "variables" {
  type = object({
    /// Non-secret pipeline variables keyed by name.
    ///
    /// @since 1.0.0
    pipeline_variables = optional(map(object({
      /// Non-secret value; an empty string is allowed.
      ///
      /// @since 1.0.0
      value = string
      /// Whether the value may be overridden at queue time; defaults to true.
      ///
      /// @since 1.0.0
      allow_override = optional(bool, true)
    })), {})

    /// Names of existing variable groups in project_name.
    ///
    /// @since 1.0.0
    variable_groups = optional(list(string), [])
  })
  description = <<EOT
    Configuration for pipeline variables and variable groups.

    - `pipeline_variables`: Map of non-secret pipeline variables to set. Values
      are stored in Terraform state; do not put sensitive information here.
    - `variable_groups`: Names of existing groups in project_name. Duplicate
      names are linked once. Linking does not grant pipeline authorization;
      restricted groups must be authorized separately in Azure DevOps.

    @since 1.0.0
  EOT
  default     = null

  validation {
    condition = var.variables == null ? true : alltrue([
      for name, config in var.variables.pipeline_variables :
      config == null ? false :
      config.value == null ? false :
      length(trimspace(name)) > 0 && name == trimspace(name)
    ])
    error_message = "Pipeline variables must have non-empty names without surrounding whitespace and non-null objects and values."
  }

  validation {
    condition = var.variables == null ? true : alltrue([
      for name in var.variables.variable_groups :
      name == null ? false : length(trimspace(name)) > 0 && name == trimspace(name)
    ])
    error_message = "Variable group names must be non-empty strings without surrounding whitespace."
  }
}

variable "permissions" {
  type = map(object({
    /// Azure DevOps user principal names, which may differ from email addresses.
    ///
    /// @since 1.0.0
    user_principal_names = optional(set(string), [])
    /// Group display names in the pipeline's project.
    ///
    /// @since 1.0.0
    groups = optional(set(string), [])
    /// Explicit graph subject descriptors, not GUIDs or security descriptors.
    ///
    /// @since 1.0.0
    descriptors = optional(set(string), [])
    /// Build-service display names.
    ///
    /// @since 1.0.0
    build_service_names = optional(set(string), [])
    /// Use replacement mode (default true), or merge mode when false.
    ///
    /// @since 1.0.0
    replace = optional(bool, true)
    /// Non-empty map of build permission names to Allow, Deny or NotSet.
    ///
    /// @since 1.0.0
    permissions = map(string)
  }))
  default     = {}
  nullable    = false
  description = <<EOT
    Named pipeline permission assignments using the repository module's
    principal selectors and permission structure. Each assignment requires at
    least one principal and one permission. Values are Allow, Deny, or NotSet.

    Names must resolve to exactly one user, project group, or svc identity.
    The same resolved principal must not appear in multiple assignments.
    Assignment names and principal inputs form resource keys; changing either
    changes the Terraform address. Explicit descriptors must be known at plan
    time. replace defaults to true; when false, NotSet cannot clear an existing
    Allow or Deny in the provider's merge mode.

    The provider documents build-definition permissions for group principals
    only. Direct user and build-service assignments are undocumented and
    should be tested in your organization before production use.

    @since 1.0.0
  EOT

  validation {
    condition = alltrue([
      for name, assignment in var.permissions :
      assignment == null ? false :
      length(trimspace(name)) > 0 &&
      length(setunion(assignment.user_principal_names, assignment.groups, assignment.descriptors, assignment.build_service_names)) > 0 &&
      alltrue([
        for principal in setunion(assignment.user_principal_names, assignment.groups, assignment.descriptors, assignment.build_service_names) :
        principal == null ? false : length(trimspace(principal)) > 0 && principal == trimspace(principal)
      ])
    ])
    error_message = "Each pipeline permission assignment needs a non-empty name and at least one non-empty principal without surrounding whitespace."
  }

  validation {
    condition = alltrue([
      for assignment in var.permissions :
      assignment == null ? false :
      assignment.permissions == null ? false :
      length(assignment.permissions) > 0 && alltrue([
        for name, permission in assignment.permissions :
        length(trimspace(name)) > 0 && name == trimspace(name) &&
        (permission == null ? false : contains(["Allow", "Deny", "NotSet"], permission))
      ])
    ])
    error_message = "Each pipeline permission assignment needs non-empty permission names without surrounding whitespace and values of Allow, Deny, or NotSet."
  }
}

variable "triggers" {
  type = object({
    /// CI override settings. Null leaves the provider's CI block unconfigured.
    ///
    /// @since 1.0.0
    continuous_integration = optional(object({
      /// Required branch inclusion and exclusion filters for enabled CI.
      ///
      /// @since 1.0.0
      branch_filters = object({
        /// Branch patterns to include; defaults to an empty list.
        ///
        /// @since 1.0.0
        include = optional(list(string), [])
        /// Branch patterns to exclude; defaults to an empty list.
        ///
        /// @since 1.0.0
        exclude = optional(list(string), [])
      })
      /// Batch changes while a build is running; defaults to false.
      ///
      /// @since 1.0.0
      batch_changes_while_a_build_is_in_progress = optional(bool, false)
      /// Enable CI; defaults to true. False applies an exclude-all override.
      ///
      /// @since 1.0.0
      enable_continuous_integration = optional(bool, true)
      /// Optional path inclusion and exclusion filters for enabled CI.
      ///
      /// @since 1.0.0
      path_filters = optional(object({
        /// Path patterns to include; defaults to an empty list.
        ///
        /// @since 1.0.0
        include = optional(list(string), [])
        /// Path patterns to exclude; defaults to an empty list.
        ///
        /// @since 1.0.0
        exclude = optional(list(string), [])
      }), {})
    }), null)

    /// Named pipeline schedules. Map keys order schedules but are not sent as
    /// schedule names to Azure DevOps. Null or {} creates no schedules.
    ///
    /// @since 1.0.0
    scheduled = optional(map(object({
      /// Non-empty list of distinct days: Mon, Tue, Wed, Thu, Fri, Sat, Sun.
      ///
      /// @since 1.0.0
      days_to_build = list(string)
      /// Local time in time_zone: h:mmAM/PM, h:mm AM/PM, HH:mm or HHmm.
      /// AM/PM is case-insensitive; 24-hour hours and minutes use two digits.
      ///
      /// @since 1.0.0
      start_time = string
      /// Provider-supported time zone display name; defaults to UTC.
      ///
      /// @since 1.0.0
      time_zone = optional(string, "(UTC) Coordinated Universal Time")
      /// Schedule only if source or pipeline changed; defaults to true.
      ///
      /// @since 1.0.0
      only_schedule_builds_if_the_source_or_pipeline_has_changed = optional(bool, true)

      /// Branch inclusion/exclusion filters for this schedule.
      ///
      /// @since 1.0.0
      branch_filters = object({
        /// Branch patterns to include; defaults to an empty list.
        ///
        /// @since 1.0.0
        include = optional(list(string), [])
        /// Branch patterns to exclude; defaults to an empty list.
        ///
        /// @since 1.0.0
        exclude = optional(list(string), [])
      })
    })), null)

    /// Existing upstream pipeline names in project_name, mapped to filters.
    ///
    /// @since 1.0.0
    build_completion = optional(map(object({
      /// Pipeline folder used for lookup; defaults to the provider's root lookup.
      ///
      /// @since 1.0.0
      path = optional(string, "\\")
      /// Branch inclusion/exclusion filters for the upstream pipeline.
      ///
      /// @since 1.0.0
      branch_filters = object({
        /// Upstream branch patterns to include; defaults to an empty list.
        ///
        /// @since 1.0.0
        include = optional(list(string), [])
        /// Upstream branch patterns to exclude; defaults to an empty list.
        ///
        /// @since 1.0.0
        exclude = optional(list(string), [])
      })
    })), null)
  })
  description = <<EOT
      Trigger configuration for the pipeline.

      continuous_integration null leaves the provider's ci_trigger block
      unconfigured. When supplied, it uses Terraform CI override settings:
      branch_filters and optional path_filters contain include/exclude lists,
      and batch_changes_while_a_build_is_in_progress defaults to false.
      enable_continuous_integration defaults to true. When false, the override
      includes and excludes "*", ignoring supplied branch/path filters to
      exclude all branches. This override has not been verified against a live
      Azure DevOps organization; other trigger types are unaffected.

      scheduled is a map of schedules with days_to_build, start_time, time_zone,
      branch_filters, and only_schedule_builds_if_the_source_or_pipeline_has_changed.
      Start times accept h:mmAM/PM (optional space before AM/PM), HH:mm, or HHmm;
      AM/PM is case-insensitive. Configured schedules override YAML schedules.
      Schedule keys determine block order, not Azure DevOps schedule names.

      build_completion maps existing upstream pipeline names in project_name to
      branch_filters and an optional pipeline folder path. The provider's
      default root path searches by name without a path filter; specify a folder
      when needed to disambiguate. Map keys determine trigger block order.

      @since 1.0.0
    EOT
  default     = null

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.continuous_integration == null ? true :
      var.triggers.continuous_integration.branch_filters != null
    )
    error_message = "continuous_integration.branch_filters must be a non-null object when continuous_integration is configured."
  }

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.continuous_integration == null ? true :
      var.triggers.continuous_integration.branch_filters == null ? true :
      alltrue([
        for filter in concat(
          var.triggers.continuous_integration.branch_filters.include,
          var.triggers.continuous_integration.branch_filters.exclude,
          var.triggers.continuous_integration.path_filters.include,
          var.triggers.continuous_integration.path_filters.exclude
        ) : filter == null ? false : length(trimspace(filter)) > 0 && filter == trimspace(filter)
      ])
    )
    error_message = "CI branch and path filters must be non-empty strings without surrounding whitespace."
  }

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.scheduled == null ? true : alltrue([
        for name, schedule in var.triggers.scheduled :
        schedule == null ? false :
        schedule.start_time == null ? false :
        length(trimspace(name)) > 0 && name == trimspace(name) && (
          can(regex("^(0?[1-9]|1[0-2]):([0-5][0-9])[ ]*([aApP][mM])$", schedule.start_time)) ||
          can(regex("^([01][0-9]|2[0-3]):?([0-5][0-9])$", schedule.start_time))
        )
      ])
    )
    error_message = "Each schedule needs a non-empty name and a valid start_time in h:mmAM/PM, h:mm AM/PM, HH:mm, or HHmm format."
  }

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.scheduled == null ? true : alltrue([
        for schedule in values(var.triggers.scheduled) :
        schedule == null ? false :
        schedule.days_to_build == null ? false :
        length(schedule.days_to_build) > 0 && length(distinct(schedule.days_to_build)) == length(schedule.days_to_build) && alltrue([
          for day in schedule.days_to_build :
          day == null ? false : contains(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], day)
        ])
      ])
    )
    error_message = "Each schedule requires at least one distinct valid day: Mon, Tue, Wed, Thu, Fri, Sat, or Sun."
  }

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.scheduled == null ? true : alltrue([
        for schedule in values(var.triggers.scheduled) :
        schedule == null ? false :
        schedule.branch_filters == null ? false :
        alltrue([
          for filter in concat(schedule.branch_filters.include, schedule.branch_filters.exclude) :
          filter == null ? false : length(trimspace(filter)) > 0 && filter == trimspace(filter)
        ])
      ])
    )
    error_message = "Each schedule requires a branch_filters object; its filters must be non-empty strings without surrounding whitespace."
  }

  validation {
    condition = var.triggers == null ? true : (
      var.triggers.build_completion == null ? true : alltrue([
        for name, trigger in var.triggers.build_completion :
        trigger == null ? false :
        trigger.branch_filters == null ? false :
        length(trimspace(name)) > 0 && name == trimspace(name) && alltrue([
          for filter in concat(trigger.branch_filters.include, trigger.branch_filters.exclude) :
          filter == null ? false : length(trimspace(filter)) > 0 && filter == trimspace(filter)
        ])
      ])
    )
    error_message = "Each build_completion entry requires a non-empty pipeline name and branch_filters object; names and filters must not have surrounding whitespace or blank values."
  }
}
