variable "name" {
  type        = string
  description = <<EOT
    Name of the S3 bucket. Must be globally unique

    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the S3 bucket

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "bucket_owner_account_id" {
  type        = string
  description = <<EOT
    The account ID of the expected bucket owner

    @since 1.0.0
  EOT
  default     = null
}

variable "cors_configurations" {
  type = list(object({
    /// List of HTTP methods that you allow the origin to execute.
    ///
    /// @enum GET|PUT|HEAD|POST|DELETE
    /// @since 1.1.0
    allowed_methods = list(string)
    /// Specify the origins that you want to allow cross-domain requests from. The origin string can contain only one `*` wildcard character, such as `"http://*.example.com"`. You can optionally specify `"*"` as the origin to enable all the origins to send cross-origin requests. You can also specify `https` to enable only secure origins.
    ///
    /// @since 1.1.0
    allowed_origins = list(string)
    /// Specify which headers are allowed in a preflight request through the Access-Control-Request-Headers header. Each header name in the Access-Control-Request-Headers header must match a corresponding entry in the element. Amazon S3 will send only the allowed headers in a response that were requested. Each header string can contain at most one `*` wildcard character. For example, `"x-amz-*"` will enable all Amazon-specific headers.
    ///
    /// @since 1.1.0
    allowed_headers = optional(list(string), null)
    /// Specify a list of headers in the response that you want customers to be able to access from their applications
    ///
    /// @since 1.1.0
    expose_headers  = optional(list(string), null)
    /// Unique identifier for the cors rule. The value cannot be longer than 255 characters.
    ///
    /// @since 1.1.0
    id              = optional(string, null)
    /// Specify the time in seconds that your browser can cache the response for a preflight request as identified by the resource, the HTTP method, and the origin.
    ///
    /// @since 1.1.0
    max_age_seconds = optional(number, null)
  }))

  description = <<EOT
    Configures [cross-origin resource sharing (CORS)][s3-cors]

    @link {s3-cors} https://docs.aws.amazon.com/AmazonS3/latest/userguide/enabling-cors-examples.html?icmpid=docs_amazons3_console
    @since 1.1.0
  EOT
  default     = null
}

variable "enables_object_lock" {
  type = object({
    /// Configures default retention rule
    ///
    /// @since 1.0.0
    default_retention = optional(object({
      /// Number of days the objects should be retained
      ///
      /// @since 1.0.0
      retention_days = number
      /// Default Object Lock retention mode you want to apply to new objects placed in the specified bucket.
      ///
      /// @enum COMPLIANCE|GOVERNANCE
      /// @since 1.0.0
      retention_mode = string
    }))

    /// Token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's "Object Lock token." The token is generated in the back-end when versioning is enabled on a bucket.
    ///
    /// @example "Enables Object Lock For Existing Bucket" #enables-object-lock-for-existing-bucket
    /// @since 1.0.0
    token = optional(string)
  })

  description = <<EOT
    Configures [S3 Object Lock][s3-object-lock]. You must also set `versioning_enabled = true` to enable object lock.

    @example "Enables Object Lock For New Bucket" #enables-object-lock-for-new-bucket
    @link {s3-object-lock} https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html
    @since 1.0.0
  EOT
  default     = null
}

variable "encryption_config" {
  type = object({
    /// Enables [S3 bucket key][s3-bucket-key] for encryption
    ///
    /// @link {s3-bucket-key} https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
    /// @since 1.0.0
    bucket_key_enabled = optional(bool)
    /// CMK arn, encrypts bucket using `sse:kms`. If this is set to `null`, `sse:s3` will be used. e.g. `arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d`
    ///
    /// @since 1.0.0
    use_kms_master_key = optional(string)
  })

  description = <<EOT
    Configures [bucket level encryption][s3-encryption]

    @link {s3-encryption} https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
    @since 1.0.0
  EOT
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = <<EOT
    Force destroy of the bucket even if it is not empty

    @since 1.0.0
  EOT
  default     = false
}

variable "intelligent_tiering_archive_configurations" {
  type = map(object({
    /// S3 Intelligent-Tiering access tier.
    ///
    /// Restore time:
    ///
    /// | Tier                | Expedited  | Standard        | Bulk
    /// |---------------------|------------|-----------------|----------------
    /// | Archive Access      | 1 - 5 mins | 3 - 5 hours     | 5 - 12 hours
    /// | Deep Archive Access | N/A        | Within 12 hours | Within 48 hours
    ///
    /// @enum ARCHIVE_ACCESS|DEEP_ARCHIVE_ACCESS
    /// @since 1.0.0
    access_tier           = string
    /// Number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier
    ///
    /// @since 1.0.0
    days_until_transition = number

    /// Limit the scope of this configuration using one or more filters
    ///
    /// @since 1.0.0
    filter = optional(object({
      /// All of these tags must exist in the object's tag set in order for the configuration to apply
      ///
      /// @since 1.0.0
      object_tags = optional(map(string), null)
      /// Object key name prefix that identifies the subset of objects to which the configuration applies
      ///
      /// @since 1.0.0
      prefix      = optional(string, null)
    }))
  }))

  description = <<EOT
    Configures [S3 intelligent tiering][s3-intelligent-tiering].

    @example "S3 Intelligent Tiering" #s3-intelligent-tiering
    @link {s3-intelligent-tiering} https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering.html
    @since 1.0.0
  EOT
  default     = {}
}

variable "inventory_config" {
  type = map(object({
    /// Specifies how frequently inventory results are produced.
    ///
    /// @enum Daily|Weekly
    /// @since 1.0.0
    frequency                  = string
    /// List of optional metadata to be included in the inventory results.
    ///
    /// @enum Size|LastModifiedDate|StorageClass|ETag|IsMultipartUploaded|ReplicationStatus|EncryptionStatus|ObjectLockRetainUntilDate|ObjectLockMode|ObjectLockLegalHoldStatus|IntelligentTieringAccessTier|BucketKeyStatus|ChecksumAlgorithm|ObjectAccessControlList|ObjectOwner|LifecycleExpirationDate
    /// @link "Available metadata field names" https://docs.aws.amazon.com/AmazonS3/latest/API/API_InventoryConfiguration.html#AmazonS3-Type-InventoryConfiguration-OptionalFields
    /// @since 1.0.0
    additional_metadata_fields = optional(list(string))

    /// Configures the destination where the report will be sent
    ///
    /// @since 1.0.0
    destination = optional(object({
      /// The account ID that owns the destination bucket. Must be set to ensure correct ownership of the report.
      ///
      /// @since 1.0.0
      account_id = optional(string)
      /// Destination bucket arn. The current bucket will be used if set to `null`
      ///
      /// @since 1.0.0
      bucket_arn = optional(string)
    }))

    /// Configures the type of server-side encryption to use to encrypt the inventory report
    ///
    /// @since 1.0.0
    encrypt_inventory_report = optional(object({
      /// ARN of the KMS customer master key (CMK) used to encrypt the inventory file. If left empty (`null`), `sse_s3` will be used for encryption
      ///
      /// @since 1.0.0
      kms_key_id = optional(string)
    }))

    /// Limit the scope of this configuration using one or more filters
    ///
    /// @since 1.0.0
    filter = optional(object({
      /// Object key name prefix that identifies the subset of objects to which the configuration applies
      ///
      /// @since 1.0.0
      prefix = optional(string, null)
    }))

    /// Specify if the report should include non current object versions
    ///
    /// @since 1.0.0
    include_noncurrent_objects = optional(bool, true)
    /// Specifies the output format of the inventory results.
    ///
    /// @enum CSV|ORC|Parquet
    /// @since 1.0.0
    output_format              = optional(string, "CSV")
  }))

  description = <<EOT
    Configures [S3 inventory][s3-inventory].

    @example "S3 Inventory" #s3-inventory
    @link {s3-inventory} https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-inventory.html
    @since 1.0.0
  EOT
  default     = {}
}

variable "lifecycle_rules" {
  type = map(object({
    /// Delete failed multipart uploads after x days
    ///
    /// @since 1.0.0
    clean_up_incomplete_multipart_uploads_after = optional(number)

    /// Expiration configuration to expires current objects
    ///
    /// @since 1.0.0
    expiration = optional(object({
      /// Permanently delete an object even if versioning is enabled
      ///
      /// @since 1.0.0
      clean_up_expired_object_delete_markers = optional(bool)
      /// Expires objects after x days
      ///
      /// @since 1.0.0
      days_after_object_creation             = optional(number)
    }))

    /// Limit the scope of this configuration using one or more filters
    ///
    /// @since 1.0.0
    filter = optional(object({
      /// Maximum object size (in bytes) to which the rule applies.
      ///
      /// @since 1.0.0
      maximum_object_size = optional(number, null)
      /// Minimum object size (in bytes) to which the rule applies.
      ///
      /// @since 1.0.0
      minimum_object_size = optional(number, null)
      /// All of these tags must exist in the object's tag set in order for the configuration to apply
      ///
      /// @since 1.0.0
      object_tags         = optional(map(string), null)
      /// Object key name prefix that identifies the subset of objects to which the configuration applies
      ///
      /// @since 1.0.0
      prefix              = optional(string, null)
    }))

    /// Expiration configuration to expires noncurrent s3 objects
    ///
    /// @since 1.0.0
    noncurrent_version_expiration = optional(object({
      /// Expires noncurrent objects after x days
      ///
      /// @since 1.0.0
      days_after_objects_become_noncurrent = number
      /// Number of noncurrent versions Amazon S3 will retain
      ///
      /// @since 1.0.0
      number_of_newer_versions_to_retain   = optional(number)
    }))

    /// Transitions noncurrent s3 objects to other storage class.
    ///
    /// @since 1.0.0
    noncurrent_version_transitions = optional(list(object({
      /// Transition noncurrent objects after x days
      ///
      /// @since 1.0.0
      days_after_objects_become_noncurrent = number
      /// Specify the destination storage class.
      ///
      /// @enum ONEZONE_IA|STANDARD_IA|INTELLIGENT_TIERING|GLACIER|DEEP_ARCHIVE|GLACIER_IR
      /// @since 1.0.0
      storage_class                        = string
      /// Number of noncurrent versions Amazon S3 will retain
      ///
      /// @since 1.0.0
      number_of_newer_versions_to_retain   = optional(number)
    })), [])

    /// Transitions s3 objects to other storage class.
    ///
    /// @since 1.0.0
    transitions = optional(list(object({
      /// Transition objects after x days
      ///
      /// @since 1.0.0
      days_after_object_creation = number
      /// Specify the destination storage class.
      ///
      /// @enum ONEZONE_IA|STANDARD_IA|INTELLIGENT_TIERING|GLACIER|DEEP_ARCHIVE|GLACIER_IR
      /// @since 1.0.0
      storage_class              = string
    })), [])
  }))

  description = <<EOT
    Configures [S3 lifecycle rules][s3-lifecycle].

    @example "Lifecycle Rules" #lifecycle-rules
    @link {s3-lifecycle} https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
    @since 1.0.0
  EOT
  default     = null
}

variable "notification_config" {
  type = object({
    /// Map of event notification in {destinationARN = [events]}. Supported AWS services include **Lambda**, **SQS**, and **SNS**. You can include up to one each **SQS** and **SNS** destination, but you can include multiple **Lambda** destinations.
    ///
    /// @since 1.0.0
    destinations = map(list(object({
      /// [S3 Events][s3-event] for which to send notifications
      ///
      /// @link {s3-event} https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations
      /// @since 1.0.0
      events        = list(string)
      /// Filters objects by key name prefix
      ///
      /// @since 1.0.0
      filter_prefix = optional(string)
      /// Filters objects by key name suffix
      ///
      /// @since 1.0.0
      filter_suffix = optional(string)
    })))
  })

  description = <<EOT
    Configures S3 event notifications.

    @example "S3 Event Notifications" #s3-event-notifications
    @since 1.0.0
  EOT
  default     = null
}

variable "object_ownership" {
  type        = string
  description = <<EOT
    Control [ownership of objects][s3-object-ownership] written to this bucket from other AWS accounts and the use of access control lists (ACLs). Object ownership determines who can specify access to objects.

    @enum BucketOwnerEnforced|BucketOwnerPreferred|ObjectWriter
    @link {s3-object-ownership} https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-new-bucket.html
    @since 1.0.0
  EOT
  default     = "BucketOwnerEnforced"
}

variable "policy" {
  type        = string
  description = <<EOT
    Text of the S3 policy document to attach

    @since 1.0.0
  EOT
  default     = null
}

variable "public_access_block" {
  type = object({
    /// Whether Amazon S3 should block public ACLs for this bucket
    ///
    /// @since 1.0.0
    block_public_acls       = optional(bool)
    /// Whether Amazon S3 should block public bucket policies for this bucket
    ///
    /// @since 1.0.0
    block_public_policy     = optional(bool)
    /// Whether Amazon S3 should ignore public ACLs for this bucket
    ///
    /// @since 1.0.0
    ignore_public_acls      = optional(bool)
    /// Whether Amazon S3 should restrict public bucket policies for this bucket
    ///
    /// @since 1.0.0
    restrict_public_buckets = optional(bool)
  })

  description = <<EOT
    Configures bucket to [block public access][public-access]

    @link {public-access} https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html
    @since 1.0.0
  EOT
  default     = null
}

variable "replication_config" {
  type = object({
    /// Configures bucket replication rules. In {rule_name = replication_config} format
    ///
    /// @since 1.0.0
    rules = map(object({
      /// ARN of the bucket where you want Amazon S3 to store the results
      ///
      /// @since 1.0.0
      destination_bucket_arn = string
      /// Priority associated with the rule. Priority must be unique between multiple rules.
      ///
      /// @since 1.0.0
      priority               = number

      /// Enables additional replication options
      ///
      /// @since 1.0.0
      additional_replication_options = optional(object({
        /// Delete markers created by S3 delete operations will be replicated. Delete markers created by lifecycle rules are not replicated.
        ///
        /// @since 1.0.0
        delete_marker_replication_enabled = optional(bool, false)
        /// Replicate metadata changes made to replicas in this bucket to the destination bucket.
        ///
        /// @since 1.0.0
        replica_modification_sync_enabled = optional(bool, false)
        /// With replication metrics, you can monitor the total number and size of objects that are pending replication, and the maximum replication time to the destination Region. You can also view and diagnose replication failures.
        ///
        /// @since 1.0.0
        replication_metrics_enabled       = optional(bool, false)
        /// Replication Time Control replicates 99.99% of new objects within 15 minutes and includes replication metrics.
        ///
        /// @since 1.0.0
        replication_time_control_enabled  = optional(bool, false)
      }))

      /// Specifies the overrides to use for object owners on replication. Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object.
      ///
      /// @since 1.0.0
      change_object_ownership_to_destination_bucket_owner = optional(object({
        /// Account ID to specify the replica ownership
        ///
        /// @since 1.0.0
        destination_account_id = string
      }))

      /// Specify the destination storage class. Defaults to the same storage class of the source object
      ///
      /// @since 1.0.0
      destination_storage_class = optional(string)

      /// Limit the scope of this configuration using one or more filters
      ///
      /// @since 1.0.0
      filter = optional(object({
        /// All of these tags must exist in the object's tag set in order for the configuration to apply
        ///
        /// @since 1.0.0
        object_tags = optional(map(string), null)
        /// Object key name prefix that identifies the subset of objects to which the configuration applies
        ///
        /// @since 1.0.0
        prefix      = optional(string, null)
      }))

      /// Specifies whether encrypted objects will be replicated
      ///
      /// @since 1.0.0
      replicate_encrypted_objects = optional(object({
        /// ARN of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) used to encrypt replicated objects
        ///
        /// @since 1.0.0
        kms_key_for_encrypting_destination_objects = string
      }))
    }))

    /// ARN of the IAM role for Amazon S3 to assume when replicating the objects. One will be automatically generated by the module if this is left empty (`null`).
    ///
    /// @since 1.0.0
    iam_role_arn = optional(string)
    /// Token to allow replication to be enabled on an Object Lock-enabled bucket. You must contact AWS support for the bucket's "Object Lock token."
    ///
    /// @link "Object lock overview" https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-overview.html#object-lock-bucket-config
    /// @since 1.0.0
    token        = optional(string)
  })

  description = <<EOT
    Manage [bucket replication][s3-bucket-replication].

    @example "S3 Bucket Replication" #s3-bucket-replication
    @link {s3-bucket-replication} https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-what-is-isnot-replicated.html
    @since 1.0.0
  EOT
  default     = null
}

variable "requester_pays_enabled" {
  type        = bool
  description = <<EOT
    Enables [Requester Pays bucket][s3-requester-pays] so that the requester pays the cost of the request and data download instead of the bucket owner. Must also specify `bucket_owner_account_id`

    @link {s3-requester-pays} https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html
    @since 1.0.0
  EOT
  default     = false
}

variable "static_website_hosting_config" {
  type = object({
    /// Configures a [webpage redirect][s3-webpage-redirect]. Mutually exclusive to `static_website`
    ///
    /// @link {s3-webpage-redirect} https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html
    /// @since 1.0.0
    redirect_requests_for_an_object = optional(object({
      /// Name of the host where requests are redirected
      ///
      /// @since 1.0.0
      host_name = string
      /// Protocol to use when redirecting requests. The default is the protocol that is used in the original request.
      ///
      /// @enum http|https
      /// @since 1.0.0
      protocol  = optional(string)
    }))

    /// Manages documents S3 returns when a request is made to its web endpoint. Mutually exclusive to `redirect_requests_for_an_object`
    ///
    /// @since 1.0.0
    static_website = optional(object({
      /// Index document when requests are made to the root domain
      ///
      /// @since 1.0.0
      index_document = string
      /// Document to return in case of a 4XX error
      ///
      /// @since 1.0.0
      error_document = optional(string)
    }))
  })

  description = <<EOT
    Configures [static website hosting][s3-static-website-hosting]

    @link {s3-static-website-hosting} https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
    @since 1.0.0
  EOT
  default     = null
}

variable "transfer_acceleration_enabled" {
  type        = bool
  description = <<EOT
    Enables [transfer acceleration][s3-transfer-acceleration]

    @link {s3-transfer-acceleration} https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html
    @since 1.0.0
  EOT
  default     = false
}

variable "versioning_enabled" {
  type        = bool
  description = <<EOT
    Enables [bucket versioning][s3-versioning]

    @link {s3-versioning} https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html
    @since 1.0.0
  EOT
  default     = false
}
