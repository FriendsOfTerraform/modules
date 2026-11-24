variable "name" {
  type        = string
  description = <<EOT
    Name of the Azure DevOps Git repository to create.

    @since 1.0.0
  EOT
}

variable "project_name" {
  type        = string
  description = <<EOT
    Name of the existing Azure DevOps project that owns the repository.
    Resolved by the shared project data source; this module does not create it.

    @since 1.0.0
  EOT
}

variable "enabled" {
  type        = bool
  description = <<EOT
    Whether the repository is enabled. Defaults to true; false disables it.
    This does not toggle individual branch or repository policies.

    @since 1.0.0
  EOT
  default     = true
}

variable "default_branch" {
  type        = string
  nullable    = false
  description = <<EOT
    The default branch of the repository, as a short name (main) or full ref
    (refs/heads/main).
    For imports and forks, the branch must exist in the source repository.
    Otherwise, a clean repository is initialized with this branch.

    @since 1.0.0
  EOT

  validation {
    condition     = length(trimspace(trimprefix(var.default_branch, "refs/heads/"))) > 0
    error_message = "The default_branch must contain a branch name."
  }
}

variable "import" {
  type = object({
    /// URL of the existing Git repository to import.
    ///
    /// @since 1.0.0
    source_repo_url = string
    /// Existing service connection used to authenticate the import.
    /// Mutually exclusive with username/password; null omits it.
    ///
    /// @since 1.0.0
    service_connection_id = optional(string, null)
    /// Source-repository username when using credential authentication.
    /// Mutually exclusive with service_connection_id; null omits it.
    ///
    /// @since 1.0.0
    username = optional(string, null)
    /// Source-repository password or token. Pass securely, not as a literal.
    /// Provider 1.16.0 treats this as write-only and does not store it in state.
    /// Mutually exclusive with service_connection_id; null omits it.
    ///
    /// @since 1.0.0
    password = optional(string, null)
  })
  description = <<EOT
    Import history from an existing Git repository. Defaults to null.
    If neither import nor fork is configured, initialization is Clean.
    Import initialization takes precedence when both are supplied.

    @since 1.0.0
  EOT
  default     = null
}

variable "fork" {
  type = object({
    /// ID of the existing Azure DevOps Git repository to fork.
    ///
    /// @since 1.0.0
    parent_repository_id = string
  })
  description = <<EOT
    Fork an existing Azure DevOps Git repository. Defaults to null.
    Used when import is null; otherwise import initialization takes precedence.

    @since 1.0.0
  EOT
  default     = null
}

variable "policy" {
  type = object({
    /// Allowed commit-author email patterns, such as "*@example.com".
    /// Supports ! exclusions; list order matters. Null creates no policy.
    ///
    /// @since 1.0.0
    commit_author_email_validation = optional(list(string), null)
    /// Blocked file-path patterns, such as "*.exe"; exact paths begin with /.
    /// Supports ! exclusions; list order matters. Null creates no policy.
    ///
    /// @since 1.0.0
    file_path_validation = optional(list(string), null)
    /// Prevent case-sensitivity conflicts in file, folder, branch and tag names.
    /// True enables, false creates a disabled policy, null creates no policy.
    ///
    /// @since 1.0.0
    case_enforcement = optional(bool, null)
    /// Block platform-reserved names and incompatible characters.
    /// True enables, false creates a disabled policy, null creates no policy.
    ///
    /// @since 1.0.0
    reserved_names = optional(bool, null)
    /// Maximum path length in characters: a whole number from 1 to 10000.
    /// Null creates no policy.
    ///
    /// @since 1.0.0
    maximum_path_length = optional(number, null)
    /// Maximum new/updated file size in MB. Null creates no policy.
    ///
    /// @enum 1|2|5|10|50|100|200
    /// @since 1.0.0
    maximum_file_size = optional(number, null)
  })
  default     = {}
  nullable    = false
  description = <<EOT
    Repository-level policy configuration. All fields default to null when
    omitted, creating no resource. Policies apply only to this repository and
    are blocking. case_enforcement and reserved_names create enabled policies
    for true and disabled policies for false; null leaves them unmanaged.
    Other configured policies are enabled.

    commit_author_email_validation allows author emails matching its patterns.
    file_path_validation blocks paths matching its patterns. Both lists must
    be non-empty; wildcard and ! exclusion patterns are passed in their original
    order. maximum_path_length is a whole number from 1 to 10000 characters.
    maximum_file_size is in MB and accepts 1, 2, 5, 10, 50, 100, or 200.
    This input is separate from each branch's policy configuration.

    @since 1.0.0
  EOT

  validation {
    condition = alltrue([
      for patterns in [var.policy.commit_author_email_validation, var.policy.file_path_validation] :
      patterns == null ? true : length(patterns) > 0 && alltrue([
        for pattern in patterns : pattern == null ? false : length(trimspace(pattern)) > 0
      ])
    ])
    error_message = "Repository email and file-path validation patterns must be null or non-empty lists of non-blank strings."
  }

  validation {
    condition = var.policy.maximum_path_length == null ? true : (
      var.policy.maximum_path_length >= 1 &&
      var.policy.maximum_path_length <= 10000 &&
      floor(var.policy.maximum_path_length) == var.policy.maximum_path_length
    )
    error_message = "maximum_path_length must be null or a whole number between 1 and 10000."
  }

  validation {
    condition     = var.policy.maximum_file_size == null ? true : contains([1, 2, 5, 10, 50, 100, 200], var.policy.maximum_file_size)
    error_message = "maximum_file_size must be null or one of 1, 2, 5, 10, 50, 100, or 200 MB."
  }
}

variable "permissions" {
  type = map(object({
    /// Azure DevOps user principal names, which may differ from email addresses.
    /// Each must resolve to exactly one user. Defaults to an empty set.
    ///
    /// @since 1.0.0
    user_principal_names = optional(set(string), [])
    /// Group display names in this repository's project, not collection groups.
    /// Each must resolve to exactly one group. Defaults to an empty set.
    ///
    /// @since 1.0.0
    groups = optional(set(string), [])
    /// Explicit graph subject descriptors, not GUIDs or security descriptors.
    /// Must be known at plan time. Defaults to an empty set.
    ///
    /// @since 1.0.0
    descriptors = optional(set(string), [])
    /// Build-service display names, such as "Project Collection Build Service (org)".
    /// Each must match exactly one svc identity. Defaults to an empty set.
    ///
    /// @since 1.0.0
    build_service_names = optional(set(string), [])
    /// Use replacement mode (default true), or merge mode when false.
    /// In merge mode, NotSet cannot clear an existing Allow or Deny.
    ///
    /// @since 1.0.0
    replace = optional(bool, true)
    /// Non-empty map of provider Git permission names to Allow, Deny or NotSet.
    /// Applied separately to every supplied principal.
    ///
    /// @since 1.0.0
    permissions = map(string)
  }))
  default     = {}
  nullable    = false
  description = <<EOT
    Named repository-wide Git permission assignments. Each assignment applies
    its permissions to every supplied user, project group, graph descriptor,
    and build-service identity. Users are identified by principal name, groups
    by display name within the repository's project, and build services by
    display name among svc identities. Name lookups must match exactly once.
    Direct user and build-service assignments are undocumented by the provider
    and should be tested in your organization before production use.

    At least one principal and one permission are required per assignment.
    Permission values are Allow, Deny, or NotSet. replace defaults to true;
    false uses the provider's merge mode, where NotSet cannot clear Allow/Deny.
    The same resolved principal must not appear twice at the same scope.
    Assignment names and principal inputs form stable resource keys; changing
    either changes the Terraform address. Explicit descriptors must be known
    when planning because they also form resource keys.

    The same structure is available under branches.<branch>.permissions, where
    scope comes from the branch key. No branch_name input is needed.

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
    error_message = "Each repository permission assignment needs a non-empty name and at least one non-empty principal without surrounding whitespace."
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
    error_message = "Each repository permission assignment needs non-empty permission names without surrounding whitespace and values of Allow, Deny, or NotSet."
  }
}

variable "branches" {
  type = map(object({
    /// Source branch, full 40-character SHA-1 commit ID, or tag.
    /// Recognized short branch names and full refs select branches; other
    /// values select tags. Null uses the repository's default branch.
    ///
    /// @since 1.0.0
    based_on = optional(string, null)

    /// Named Git permission assignments scoped to this exact branch key.
    /// Uses the root permissions schema; wildcard keys cannot assign permissions.
    /// Defaults to an empty map.
    ///
    /// @since 1.0.0
    permissions = optional(map(object({
      /// User principal names, not necessarily email addresses; defaults to [].
      ///
      /// @since 1.0.0
      user_principal_names = optional(set(string), [])
      /// Unique group display names within the repository's project; defaults to [].
      ///
      /// @since 1.0.0
      groups = optional(set(string), [])
      /// Graph subject descriptors known at plan time, not GUIDs; defaults to [].
      ///
      /// @since 1.0.0
      descriptors = optional(set(string), [])
      /// Display names resolving to exactly one svc identity; defaults to [].
      ///
      /// @since 1.0.0
      build_service_names = optional(set(string), [])
      /// Replacement mode by default; false merges and cannot clear via NotSet.
      ///
      /// @since 1.0.0
      replace = optional(bool, true)
      /// Non-empty map of Git permission names to Allow, Deny or NotSet.
      ///
      /// @since 1.0.0
      permissions = map(string)
    })), {})

    /// Named auto-reviewer policies. Names distinguish policies with identical
    /// reviewer lists and form stable addresses with the branch key.
    /// Defaults to an empty map.
    ///
    /// @since 1.0.0
    automatically_included_reviewers = optional(map(object({
      /// User principal names; resolved descriptors are converted to reviewer IDs.
      /// Defaults to []; at least one user or group is required.
      ///
      /// @since 1.0.0
      users = optional(list(string), [])
      /// Group names in the repository's project; converted to reviewer IDs.
      /// Defaults to []; at least one user or group is required.
      ///
      /// @since 1.0.0
      groups = optional(list(string), [])
      /// Whether this policy is enabled; defaults to true.
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
      /// Required blocks completion; optional does not. Defaults to required.
      ///
      /// @enum required|optional
      /// @since 1.0.0
      policy_requirement = optional(string, "required")
      /// Provider path filters controlling when reviewers are included.
      /// Null omits path filtering.
      ///
      /// @since 1.0.0
      path_filters = optional(list(string), null)
      /// Whether the pull-request author may satisfy their own reviewer vote.
      /// Defaults to true.
      ///
      /// @since 1.0.0
      allow_requestors_to_approve_their_own_changes = optional(bool, true)
      /// Message posted when reviewers are automatically included; null omits it.
      ///
      /// @since 1.0.0
      activity_feed_message = optional(string, null)
    })), {})

    /// Named build-validation policies for existing pipelines in the project.
    /// Defaults to an empty map.
    ///
    /// @since 1.0.0
    build_validations = optional(map(object({
      /// Expiration duration: bare whole numbers are minutes; supported units
      /// are seconds, minutes, hours, days, weeks, months and years.
      /// Seconds must convert to whole minutes; months=30 days, years=365 days.
      /// "immediately" expires on target-branch updates; null/"0" never expires
      /// on target updates. Source updates still invalidate previous builds.
      /// Manual positive durations must not exceed 527040 minutes.
      ///
      /// @since 1.0.0
      build_expires_after = optional(string)
      /// Existing root-folder pipeline name; null uses the validation map key.
      ///
      /// @since 1.0.0
      build_pipeline_name = optional(string, null)
      /// Whether this policy is enabled; defaults to true.
      ///
      /// @since 1.0.0
      enabled = optional(bool, true)
      /// Provider filename patterns selecting changes requiring validation.
      /// Null omits path filtering.
      ///
      /// @since 1.0.0
      path_filters = optional(list(string), null)
      /// Required blocks completion; optional does not. Defaults to required.
      ///
      /// @enum required|optional
      /// @since 1.0.0
      policy_requirement = optional(string, "required")
      /// Automatic queues validation automatically; manual requires manual queuing.
      /// Defaults to automatic; independent of the expiration setting.
      ///
      /// @enum automatic|manual
      /// @since 1.0.0
      trigger = optional(string, "automatic")
    })), {})

    /// Branch policies applied with Exact matching or Prefix for trailing * keys.
    /// Defaults to {}, which enables the default all-merge-types policy.
    ///
    /// @since 1.0.0
    policy = optional(object({
      /// Require resolved PR comments: required blocks, optional does not.
      /// Null creates no policy.
      ///
      /// @enum required|optional
      /// @since 1.0.0
      check_for_comment_resolution = optional(string, null)
      /// Require linked work items: required blocks, optional does not.
      /// Null creates no policy. The existing input spelling is intentional.
      ///
      /// @enum required|optional
      /// @since 1.0.0
      check_for_lined_work_items = optional(string, null)

      /// Allowed pull-request merge strategies; all default to true.
      ///
      /// @since 1.0.0
      allowed_merge_types = optional(object({
        /// Allow a basic merge commit without fast-forwarding.
        ///
        /// @since 1.0.0
        basic_no_fast_forward = optional(bool, true)
        /// Allow rebase followed by fast-forward.
        ///
        /// @since 1.0.0
        rebase_and_fast_forward = optional(bool, true)
        /// Allow rebase followed by a merge commit.
        ///
        /// @since 1.0.0
        rebase_and_merge_commit = optional(bool, true)
        /// Allow squashing changes into a single commit.
        ///
        /// @since 1.0.0
        squash = optional(bool, true)
      }), {})

      /// Minimum-reviewer policy settings; null creates no policy.
      ///
      /// @since 1.0.0
      require_a_minimum_number_of_reviewers = optional(object({
        /// Required approving reviewer count.
        ///
        /// @since 1.0.0
        minimum_number_of_reviewers = number
        /// Count the PR author's approval; defaults to false.
        ///
        /// @since 1.0.0
        allow_requestors_to_approve_their_own_changes = optional(bool, false)
        /// Exclude approval by the most recent pusher; defaults to false.
        ///
        /// @since 1.0.0
        prohibit_the_most_recent_pusher_from_approving_their_own_changes = optional(bool, false)
        /// Allow completion despite reject/wait votes; defaults to false.
        ///
        /// @since 1.0.0
        allow_completion_even_if_some_reviewers_vote_to_wait_or_reject = optional(bool, false)
        /// Vote behavior after new pushes. Null leaves reset/iteration flags unset.
        /// reset_all_votes also resets approvals; reset_all_approval_votes only
        /// resets approvals. Iteration modes require a vote on each or last iteration.
        ///
        /// @enum require_vote_on_each_iteration|require_vote_on_last_iteration|reset_all_approval_votes|reset_all_votes
        /// @since 1.0.0
        when_new_changes_are_pushed = optional(string, null)
      }), null)
    }), {})
  }))

  description = <<EOT
    Manages the branches of the repository. Branch keys accept short names or
    full refs; each branch must be listed only once, regardless of format.
    The default branch and trailing * policy entries are not created as branch
    resources. Other entries are created and returned by the branches output,
    keyed by their original input keys. Defaults to an empty map.

    based_on selects a branch in this map or the default branch by short name
    or full ref. A full refs/heads/ ref also selects an existing branch outside
    this map. A full 40-character commit ID selects a commit; other values
    select a tag. If null, the repository's default branch is used.

    Each build validation identifies an existing pipeline in the project's root
    folder. If build_pipeline_name is omitted, the validation map key is used.
    build_expires_after accepts "immediately" for immediate expiration, null
    or "0" for no expiration, or a non-negative whole number with an optional
    unit (seconds, minutes, hours, days, weeks, months, or years). A bare number
    is in minutes; seconds must be a whole number of minutes. Months are 30
    days and years are 365 days. Automatic validations are queued on pull
    requests and source updates, which always expire their previous build.
    For manual validations, a positive duration expires the build on source
    updates and must not exceed 527040 minutes (366 days).
    policy_requirement is "required" for a blocking policy or "optional" for
    a non-blocking policy.

    Each branch entry creates a merge-types policy. All merge types are allowed
    by default; set individual allowed_merge_types fields to false to limit them.
    Set check_for_comment_resolution to "required" or "optional" to enable a
    blocking or non-blocking comment-resolution policy; null creates no policy.
    check_for_lined_work_items uses the same values for work-item linking.

    automatically_included_reviewers is a map of named policies per branch.
    Each policy specifies users by Azure DevOps principal name (which can differ
    from email addresses) and groups by project group name. At least one user or
    group is required. policy_requirement must be "required" or "optional".
    Policy addresses use the branch and policy map keys; changing either key
    changes its address.

    permissions uses the same named-assignment structure as the root permissions
    input, but applies to this branch. Short names and full refs are accepted.
    Wildcard branch keys cannot contain permission assignments; Git permissions
    do not use branch-policy wildcard matching.

    @since 1.0.0
  EOT
  default     = {}

  validation {
    condition = alltrue([
      for name, branch in var.branches :
      length(branch.permissions) == 0 || !strcontains(name, "*")
    ])
    error_message = "Permission assignments require an exact branch key without wildcards."
  }

  validation {
    condition = alltrue([
      for branch in values(var.branches) : alltrue([
        for name, assignment in branch.permissions :
        assignment == null ? false :
        length(trimspace(name)) > 0 &&
        length(setunion(assignment.user_principal_names, assignment.groups, assignment.descriptors, assignment.build_service_names)) > 0 &&
        alltrue([
          for principal in setunion(assignment.user_principal_names, assignment.groups, assignment.descriptors, assignment.build_service_names) :
          principal == null ? false : length(trimspace(principal)) > 0 && principal == trimspace(principal)
        ])
      ])
    ])
    error_message = "Each branch permission assignment needs a non-empty name and at least one non-empty principal without surrounding whitespace."
  }

  validation {
    condition = alltrue([
      for branch in values(var.branches) : alltrue([
        for assignment in branch.permissions :
        assignment == null ? false :
        assignment.permissions == null ? false :
        length(assignment.permissions) > 0 && alltrue([
          for name, permission in assignment.permissions :
          length(trimspace(name)) > 0 && name == trimspace(name) &&
          (permission == null ? false : contains(["Allow", "Deny", "NotSet"], permission))
        ])
      ])
    ])
    error_message = "Each branch permission assignment needs non-empty permission names without surrounding whitespace and values of Allow, Deny, or NotSet."
  }

  validation {
    condition = (
      alltrue([for name in keys(var.branches) : length(trimspace(trimprefix(name, "refs/heads/"))) > 0]) &&
      length(distinct([for name in keys(var.branches) : trimprefix(name, "refs/heads/")])) == length(var.branches)
    )
    error_message = "Branch keys must contain a name and must not identify the same branch in both short and full-ref forms."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for name, policy in branch.automatically_included_reviewers :
        length(trimspace(name)) > 0 && length(policy.users) + length(policy.groups) > 0 && alltrue([
          for reviewer in concat(policy.users, policy.groups) :
          reviewer == null ? false : length(trimspace(reviewer)) > 0 && reviewer == trimspace(reviewer)
        ])
      ]
    ]))
    error_message = "Each auto-reviewer policy needs a non-empty name and at least one non-empty user or group without surrounding whitespace."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for policy in branch.automatically_included_reviewers :
        contains(["required", "optional"], policy.policy_requirement)
      ]
    ]))
    error_message = "Each auto-reviewer policy_requirement must be required or optional."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for name, build in branch.build_validations :
        build.build_pipeline_name == null ? length(trimspace(name)) > 0 : length(trimspace(build.build_pipeline_name)) > 0
      ]
    ]))
    error_message = "Each build validation must resolve to a non-empty pipeline name, using build_pipeline_name or its map key."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for build in values(branch.build_validations) :
        build.build_expires_after == null ? true :
        build.build_expires_after == "immediately" ? true :
        !can(regex("^([0-9]+)(?:[[:space:]]+(second|minute|hour|day|week|month|year)s?)?$", trimspace(build.build_expires_after))) ? false :
        startswith(coalesce(regex("^([0-9]+)(?:[[:space:]]+(second|minute|hour|day|week|month|year)s?)?$", trimspace(build.build_expires_after))[1], "minute"), "second") ?
        tonumber(regex("^([0-9]+)", trimspace(build.build_expires_after))[0]) % 60 == 0 : true
      ]
    ]))
    error_message = "build_expires_after must be null, immediately, or a non-negative whole number with an optional supported time unit; seconds must be a multiple of 60."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for build in values(branch.build_validations) :
        contains(["automatic", "manual"], build.trigger)
      ]
    ]))
    error_message = "Each build validation trigger must be automatic or manual."
  }

  validation {
    condition = alltrue(flatten([
      for branch in values(var.branches) : [
        for build in values(branch.build_validations) :
        contains(["required", "optional"], build.policy_requirement)
      ]
    ]))
    error_message = "Each build validation policy_requirement must be required or optional."
  }

  validation {
    condition = alltrue([
      for branch in values(var.branches) :
      branch.policy.check_for_lined_work_items == null ? true :
      contains(["required", "optional"], branch.policy.check_for_lined_work_items)
    ])
    error_message = "check_for_lined_work_items must be required, optional, or null."
  }

  validation {
    condition = alltrue([
      for branch in values(var.branches) :
      branch.policy.check_for_comment_resolution == null ? true :
      contains(["required", "optional"], branch.policy.check_for_comment_resolution)
    ])
    error_message = "check_for_comment_resolution must be required, optional, or null."
  }

  validation {
    condition = alltrue([
      for branch in values(var.branches) :
      branch.policy.require_a_minimum_number_of_reviewers == null ? true :
      branch.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed == null ? true :
      contains(
        ["require_vote_on_each_iteration", "require_vote_on_last_iteration", "reset_all_approval_votes", "reset_all_votes"],
        branch.policy.require_a_minimum_number_of_reviewers.when_new_changes_are_pushed
      )
    ])
    error_message = "when_new_changes_are_pushed must be require_vote_on_each_iteration, require_vote_on_last_iteration, reset_all_approval_votes, reset_all_votes, or null."
  }
}
