variable "name" {
  type        = string
  description = "Name must be globally unique."
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the S3 bucket."
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "bucket_owner_account_id" {
  type        = string
  description = "Account ID of the expected bucket owner"
  default     = null
}

variable "encryption_config" {
  type = object({
    use_kms_master_key = string
    bucket_key_enabled = optional(bool)
  })

  description = "Enable bucket level encryption."
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy bucket"
  default     = false
}

variable "lifecycle_rules" {
  type = map(object({
    filter = optional(object({
      prefix              = optional(string, null)
      object_tags         = optional(map(string), null)
      minimum_object_size = optional(number, null)
      maximum_object_size = optional(number, null)
    }))

    clean_up_incomplete_multipart_uploads_after = optional(number)

    expiration = optional(object({
      days_after_object_creation             = optional(number)
      clean_up_expired_object_delete_markers = optional(bool)
    }))

    transitions = optional(list(object({
      days_after_object_creation = number
      storage_class              = string
    })), [])

    noncurrent_version_expiration = optional(object({
      days_after_objects_become_noncurrent = number
      number_of_newer_versions_to_retain   = optional(number)
    }))

    noncurrent_version_transitions = optional(list(object({
      days_after_objects_become_noncurrent = number
      number_of_newer_versions_to_retain   = optional(number)
      storage_class                        = string
    })), [])
  }))

  description = "Configure lifecycle rules to rotate out objects. In {rule_name = lifecycle_config} format."
  default     = null
}

variable "notification_config" {
  type = object({
    destinations = map(list(object({
      events        = list(string)
      filter_prefix = string
      filter_suffix = string
    })))
  })

  description = "Configuration to enable bucket event notification. Destination is in {dest_arn = config} format."
  default     = null
}

variable "object_lock_enabled" {
  type        = bool
  description = "Indicates whether this bucket has an Object Lock configuration enabled"
  default     = false
}

variable "policy" {
  type        = string
  description = "Policy document for the bucket policy."
  default     = null
}

variable "public_access_block" {
  type = object({
    block_public_acls       = optional(bool)
    block_public_policy     = optional(bool)
    ignore_public_acls      = optional(bool)
    restrict_public_buckets = optional(bool)
  })

  description = "Block public access to bucket"

  default = null
}

variable "static_website_hosting_config" {
  type = object({
    static_website = optional(object({
      index_document = string
      error_document = optional(string)
    }))

    redirect_requests_for_an_object = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
  })

  description = "Configuration to enable bucket for static web hosting."
  default     = null
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable S3 versioning."
  default     = false
}