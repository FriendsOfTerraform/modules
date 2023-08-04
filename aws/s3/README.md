# AWS S3 Module

This module configures and manages an S3 bucket and its various configurations such as static website and lifecycle rules.

## Table of Contents

- [Example Usage](#example-usage)
    - [Static Web Hosting](#static-web-hosting)
    - [Lifecycle Rules](#lifecycle-rules)
    - [S3 Event Notifications](#s3-event-notifications)
    - [Bucket Level Encryption](#bucket-level-encryption)
    - [S3 Intelligent Tiering](#s3-intelligent-tiering)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Static Web Hosting

This example uses a public read bucket policy to allow anonymous access to all objects in the bucket.

```terraform
module "static_web_hosting" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.0.0"

  name = "demo-bucket"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::demo-bucket/*"
    }
  }
  EOF

  static_website_hosting_config = {
    static_website = {
      index_document = "index.html"
      error_document = "error.html"
    }
  }
}
```

### Lifecycle Rules

This example shows a basic lifecycle rule to auto rotate logs that are tagged with “AutoRotate = true” that are saved in the “log/” path. After 30 days, the logs will be transitioned to the `STANDARD_IA` storage class, then to the `GLACIER` storage class after another 60 days. Finally, all logs will be expired (deleted) after another 90 days. Additionally, delete markers will be cleaned up, effectively making the deletion permanent if versoning is enabled. All previous versioned objects will be expired after 60 days.

```terraform
module "lifecycle_rule_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.0.0"

  name               = "demo-bucket"
  versioning_enabled = true

  lifecycle_rules = {
    "rotate-logs" = {
      # This rule is scoped to objects with prefix AND tags
      filter = {
        prefix = "log/"

        object_tags = {
          AutoRotate = "true"
        }
      }

      transitions = [
        {
          days_after_object_creation = 30
          storage_class              = "STANDARD_IA"
        },
        {
          days_after_object_creation = 90
          storage_class              = "GLACIER"
        }
      ]

      expiration = {
        days_after_object_creation             = 180
        clean_up_expired_object_delete_markers = true
      }

      noncurrent_version_expiration = {
        days_after_objects_become_noncurrent = 60
      }
    }
  }
}
```

### S3 Event Notifications

This example configures the bucket to send notifications to a lambda function to process .jpg files uploaded into the “photo/” folder. It also configures the bucket to send notification to an SNS topic to notify administrators of all deletion events.

```terraform
locals {
  lambda_arn = "arn:aws:lambda:us-west-2:111122223333:function:ProcessPhotos",
  sns_arn = "arn:aws:sns:us-west-2:111122223333:Admins"
}

module "bucket_notification_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.0.0"

  name = "demo-bucket"

  notification_config = {
    destinations = {
      local.lambda_arn = [{
        events        = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
        filter_prefix = "photo/"
        filter_suffix = ".jpg"
      },
      {
        events = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
        filter_prefix = "video/"
        filter_suffix = ".mpeg"
      }],
      local.sns_arn = [{
        events = ["s3:ObjectRemoved:*"]
      }]
    }
  }
}
```

#### Notes

- You must ensure proper permissions are granted to S3 on each destination. Refers to the following documentations for more detail:
    - [Lambda Permission][lambda-resource-based-policy]
    - [SNS Permission](#blank)
    - [SQS Permission](#blank)

### Bucket Level Encryption

```terraform
module "bucket_encryption_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.0.0"

  name = "demo-bucket"

  encryption_config = {
    use_kms_master_key = "arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d"
    bucket_key_enabled = true
  }
}
```

#### Notes

- This example enables bucket level encryption using SSE:KMS. To use SSE:S3 instead, set `use_kms_master_key` to null.

### S3 Intelligent Tiering

```terraform
module "s3_intelligent_tiering_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.0.0"

  name = "demo-bucket"

  intelligent_tiering_archive_configurations = {
    # Archive logs after 180 days of no access
    "archive-logs" = {
      filter = {
        prefix = "logs*"
      }

      access_tier           = "ARCHIVE_ACCESS"
      days_until_transition = 180
    }

    # Deeply achive backups after 90 days of no access
    "archive-backup" = {
      access_tier           = "DEEP_ARCHIVE_ACCESS"
      days_until_transition = 90
    }
  }
}
```

#### Notes

- You must grant the necessary permissions to the source and destination bucket via bucket policy.
- [bucket permission][s3-inventory-bucket-permission]

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

  Name of the S3 bucket. Must be globally unique

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

  Additional tags for the S3 bucket

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

  Additional tags for all resources deployed with this module

- (string) **`bucket_owner_account_id = null`** _[since v1.0.0]_

  The account ID of the expected bucket owner

- (object) **`encryption_config = null`** _[since v1.0.0]_

  Configures [bucket level encryption][s3-encryption]

  ```terraform
  encryption_config = {
    use_kms_master_key = "arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d"
    bucket_key_enabled = true
  }
  ```

  - (bool) **`bucket_key_enabled = false`** _[since v1.0.0]_

    Enables [S3 bucket key][s3-bucket-key] for encryption

  - (string) **`use_kms_master_key = null`** _[since v1.0.0]_

    CMK arn, encrypts bucket using `sse:kms`. If this is set to `null`, `sse:s3` will be used. e.g. `arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d`

- (bool) **`force_destroy = false`** _[since v1.0.0]_

    Force destroy of the bucket even if it is not empty

- (map(object)) **`intelligent_tiering_archive_configurations = {}`** _[since v1.0.0]_

    Configures [S3 intelligent tiering][s3-intelligent-tiering]. In {rule_name = intelligent_tiering_config} format

    - (string) **`access_tier`** _[since v1.0.0]_

        S3 Intelligent-Tiering access tier. Valid values are `"ARCHIVE_ACCESS"` and `"DEEP_ARCHIVE_ACCESS"`

        Restore time:
        | Tier                | Expedited  | Standard        | Bulk
        |---------------------|------------|-----------------|----------------
        | Archive Access      | 1 - 5 mins | 3 - 5 hours     | 5 - 12 hours
        | Deep Archive Access | N/A        | Within 12 hours | Within 48 hours

    - (number) **`days_until_transition`** _[since v1.0.0]_

        Number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier

    - (object) **`filter = null`** _[since v1.0.0]_

        Limit the scope of this configuration using one or more filters

        - (string) **`prefix = null`** _[since v1.0.0]_

            Object key name prefix that identifies the subset of objects to which the configuration applies

        - (map(string)) **`object_tags = null`** _[since v1.0.0]_

            All of these tags must exist in the object's tag set in order for the configuration to apply

- (map(object)) **`inventory_config = {}`** _[since v1.0.0]_

    Configures [S3 inventory][s3-inventory]. In {rule_name = inventory_config} format

    - (string) **`frequency`** _[since v1.0.0]_

        Specifies how frequently inventory results are produced. Valid values: `"Daily"`, `"Weekly"`

    - (list(string)) **`additional_metadata_fields = null`** _[since v1.0.0]_

        List of optional metadatas to be included in the inventory results. Please refer to this [documentation][s3-inventory-metadata] for a list of valid values.

    - (object) **`destination = null`** _[since v1.0.0]_

        Configures the destination where the report will be sent

        - (string) **`bucket_arn = null`** _[since v1.0.0]_

            Destination bucket arn. The same bucket will be used if set to `null`

        - (string) **`account_id = null`** _[since v1.0.0]_

            The account ID that owns the destination bucket. Must be set to ensure correct ownership of the report.

    - (object) **`encrypt_inventory_report = null`** _[since v1.0.0]_

        Configures the type of server-side encryption to use to encrypt the inventory report

        - (string) **`kms_key_id = null`** _[since v1.0.0]_

            ARN of the KMS customer master key (CMK) used to encrypt the inventory file. If left empty (`null`), `sse_s3` will be used for encryption

    - (object) **`filter = null`** _[since v1.0.0]_

        Limit the scope of this configuration using one or more filters

        - (string) **`prefix = null`** _[since v1.0.0]_

            Object key name prefix that identifies the subset of objects to which the configuration applies

    - (bool) **`include_noncurrent_objects = true`** _[since v1.0.0]_

        Specify if the report should include non current object versions

    - (string) **`output_format = "CSV"`** _[since v1.0.0]_

        Specifies the output format of the inventory results. Can be `"CSV"`, `"ORC"` or `"Parquet"`

- (map(object)) **`lifecycle_rules = null`** _[since v1.0.0]_

    Configures S3 lifecycle rules in {ruleName = ruleConfig}

    - (object) **`filter = null`** _[since v1.0.0]_

        Limit the scope of this configuration using one or more filters

        - (string) **`prefix = null`** _[since v1.0.0]_

            Object key name prefix that identifies the subset of objects to which the configuration applies

        - (map(string)) **`object_tags = null`** _[since v1.0.0]_

            All of these tags must exist in the object's tag set in order for the configuration to apply

        - (number) **`minimum_object_size = null`** _[since v1.0.0]_

            Minimum object size (in bytes) to which the rule applies.

        - (number) **`maximum_object_size = null`** _[since v1.0.0]_

            Maximum object size (in bytes) to which the rule applies.

    - (number) **`clean_up_incomplete_multipart_uploads_after = null`** _[since v1.0.0]_

        Delete failed multipart uploads after x days

    - (object) **`expiration = null`** _[since v1.0.0]_

        Expiration configuration to expires current objects

        - (bool) **`clean_up_expired_object_delete_markers = false`** _[since v1.0.0]_

            Permanently delete an object even if versioning is enabled

        - (number) **`days_after_object_creation = null`** _[since v1.0.0]_

            Expires objects after x days

    - (object) **`noncurrent_version_expiration = null`** _[since v1.0.0]_

        Expiration configuration to expires noncurrent s3 objects

        - (number) **`days_after_objects_become_noncurrent`** _[since v1.0.0]_

            Expires noncurrent objects after x days

        - (number) **`number_of_newer_versions_to_retain = null`** _[since v1.0.0]_

            Number of noncurrent versions Amazon S3 will retain

    - (list(object)) **`noncurrent_version_transitions = []`** _[since v1.0.0]_

        Transitions noncurrent s3 objects to other storage class.

        - (number) **`days_after_objects_become_noncurrent`** _[since v1.0.0]_

            Transition noncurrent objects after x days

        - (string) **`storage_class`** _[since v1.0.0]_

            Specify the destination storage class. Valid values: `"ONEZONE_IA"`, `"STANDARD_IA"`, `"INTELLIGENT_TIERING"`, `"GLACIER"`, `"DEEP_ARCHIVE"`, or `"GLACIER_IR"`

        - (number) **`number_of_newer_versions_to_retain = null`** _[since v1.0.0]_

            Number of noncurrent versions Amazon S3 will retain

    - (list(object)) **`transitions`** _[since v1.0.0]_

        Transitions s3 objects to other storage class.

        - (number) **`days_after_object_creation`** _[since v1.0.0]_

            Transition objects after x days

        - (string) **`storage_class`** _[since v1.0.0]_

            Specify the destination storage class. Valid values: `"ONEZONE_IA"`, `"STANDARD_IA"`, `"INTELLIGENT_TIERING"`, `"GLACIER"`, `"DEEP_ARCHIVE"`, or `"GLACIER_IR"`

- (object) **`notification_config = null`** _[since v1.0.0]_

    Configures S3 event notifiactions

    - (map(list(object))) **`destinations`** _[since v1.0.0]_

        Map of event notification in {destinationARN = [events]}. Supported AWS services include **Lambda**, **SQS**, and **SNS**. You can include up to one each **SQS** and **SNS** destination, but you can include multiple **Lambda** destinations.

        - (list(string)) **`events`** _[since v1.0.0]_

            [S3 Events][s3-event] for which to send notifications

        - (string) **`filter_prefix = null`** _[since v1.0.0]_

            Filters objects by key name prefix

        - (string) **`filter_suffix = null`** _[since v1.0.0]_

            Filters objects by key name suffix

- (string) **`policy = null`** _[since v1.0.0]_

    Text of the S3 policy document to attach

- (object) **`public_access_block = null`** _[since v1.0.0]_

    Configures bucket to [block public access][public-access]

    - (bool) **`block_public_acls = false`** _[since v1.0.0]_

        Whether Amazon S3 should block public ACLs for this bucket

    - (bool) **`block_public_policy  = false`** _[since v1.0.0]_

        Whether Amazon S3 should block public bucket policies for this bucket

    - (bool) **`ignore_public_acls = false`** _[since v1.0.0]_

        Whether Amazon S3 should ignore public ACLs for this bucket

    - (bool) **`restrict_public_buckets = false`** _[since v1.0.0]_

        Whether Amazon S3 should restrict public bucket policies for this bucket

- (object) **`replication_config = null`** _[since v1.0.0]_

    Manage [bucket replicatoin][s3-bucket-replication]

    - (map(object)) **`rules`** _[since v1.0.0]_

        Configures bucket replicatoin rules. In {rule_name = replication_config} format

        - (string) **`destination_bucket_arn`** _[since v1.0.0]_

            ARN of the bucket where you want Amazon S3 to store the results

        - (number) **`priority`** _[since v1.0.0]_

            Priority associated with the rule. Priority must be unique between multiple rules.

        - (object) **`additional_replication_options = null`** _[since v1.0.0]_

            Enables additional replication options

            - (bool) **`replication_time_control_enabled = false`** _[since v1.0.0]_

                Replication Time Control replicates 99.99% of new objects within 15 minutes and includes replication metrics.

            - (bool) **`replication_metrics_enabled = false`** _[since v1.0.0]_

                With replication metrics, you can monitor the total number and size of objects that are pending replication, and the maximum replication time to the destination Region. You can also view and diagnose replication failures.

            - (bool) **`delete_marker_replication_enabled = false`** _[since v1.0.0]_

                Delete markers created by S3 delete operations will be replicated. Delete markers created by lifecycle rules are not replicated.

            - (bool) **`replica_modification_sync_enabled = false`** _[since v1.0.0]_

                Replicate metadata changes made to replicas in this bucket to the destination bucket.

        - (object) **`change_object_ownership_to_destination_bucket_owner = null`** _[since v1.0.0]_

            specifies the overrides to use for object owners on replication. Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object.

            - (string) **`destination_account_id`** _[since v1.0.0]_

                Account ID to specify the replica ownership

        - (string) **`destination_storage_class = null`** _[since v1.0.0]_

            Specify the destination storage class. Defaults to the same storage class of the source object

        - (object) **`replicate_encrypted_objects = null`** _[since v1.0.0]_

            specifies whether encrypted objects will be replicated

            - (string) **`kms_key_for_encrypting_destination_objects`** _[since v1.0.0]_

                ARN of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) used to encrypt replicated objects

        - (object) **`filter = null`** _[since v1.0.0]_

            Limit the scope of this configuration using one or more filters

            - (string) **`prefix = null`** _[since v1.0.0]_

                Object key name prefix that identifies the subset of objects to which the configuration applies

            - (map(string)) **`object_tags = null`** _[since v1.0.0]_

                All of these tags must exist in the object's tag set in order for the configuration to apply

    - (string) **`iam_role_arn = null`** _[since v1.0.0]_

        ARN of the IAM role for Amazon S3 to assume when replicating the objects. One will be automatically generated by the module if this is left empty (`null`).

    - (string) **`token = null`** _[since v1.0.0]_

        Token to allow replication to be enabled on an Object Lock-enabled bucket. You must contact AWS support for the bucket's "Object Lock token"

- (bool) **`requester_pays_enabled = false`** _[since v1.0.0]_

    Enables [Requester Pays bucket][s3-requester-pays] so that the requester pays the cost of the request and data download instead of the bucket owner. Must also specify `bucket_owner_account_id`

- (object) **`static_website_hosting_config = null`** _[since v1.0.0]_

    Configures [static website hosting][s3-static-website-hosting]

    - (object) **`static_website = null`** _[since v1.0.0]_

        Manages documents S3 returns when a request is made to its web endpoint. Mutually exclusive to `redirect_requests_for_an_object`

        - (string) **`index_document`** _[since v1.0.0]_

            Index document when requests are made to the root domain

        - (string) **`error_document = null`** _[since v1.0.0]_

            Document to return in case of a 4XX error

    - (object) **`redirect_requests_for_an_object = null`** _[since v1.0.0]_

        Configures a [webpage redirect][s3-webpage-redirect]. Mutually exclusive to `static_website`

        - (string) **`host_name`** _[since v1.0.0]_

            Name of the host where requests are redirected

        - (string) **`protocol = null`** _[since v1.0.0]_

            Protocol to use when redirecting requests. The default is the protocol that is used in the original request. Valid values: `"http"`, `"https"`

- (bool) **`transfer_acceleration_enabled = false`** _[since v1.0.0]_

    Enables [transfer acceleration][s3-transfer-acceleration]

- (bool) **`versioning_enabled = false`** _[since v1.0.0]_

    Enables [bucket versioning][s3-versioning]

## Outputs

- (string) **`bucket_name`** _[since v1.0.0]_

    Name of the S3 bucket

- (string) **`bucket_arn`** _[since v1.0.0]_

    ARN of the S3 bucket

[lambda-resource-based-policy]:https://docs.aws.amazon.com/lambda/latest/dg/access-control-resource-based.html
[bucket-policy]:https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html
[public-access]:https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html
[s3-bucket-key]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
[s3-bucket-replication]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-what-is-isnot-replicated.html
[s3-encryption]:https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
[s3-event]:https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations
[s3-intelligent-tiering]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering.html
[s3-inventory]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-inventory.html
[s3-inventory-metadata]:https://docs.aws.amazon.com/AmazonS3/latest/API/API_InventoryConfiguration.html#AmazonS3-Type-InventoryConfiguration-OptionalFields
[s3-inventory-bucket-permission]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-s3-inventory-1
[s3-requester-pays]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html
[s3-static-website-hosting]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html
[s3-transfer-acceleration]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html
[s3-versioning]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html
[s3-webpage-redirect]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html
