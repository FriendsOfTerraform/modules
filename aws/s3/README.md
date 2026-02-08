# AWS S3 Module

This module configures and manages an S3 bucket and its various configurations such as static website and lifecycle rules.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Static Web Hosting](#static-web-hosting)
    - [Lifecycle Rules](#lifecycle-rules)
    - [S3 Event Notifications](#s3-event-notifications)
    - [Bucket Level Encryption](#bucket-level-encryption)
    - [S3 Intelligent Tiering](#s3-intelligent-tiering)
    - [S3 Inventory](#s3-inventory)
    - [S3 Bucket Replication](#s3-bucket-replication)
    - [Enables Object Lock For New Bucket](#enables-object-lock-for-new-bucket)
    - [Enables Object Lock For Existing Bucket](#enables-object-lock-for-existing-bucket)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "demo_bucket" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"
}
```

### Static Web Hosting

This example uses a public read bucket policy to allow anonymous access to all objects in the bucket.

```terraform
module "static_web_hosting" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

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
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name               = "demo-bucket"
  versioning_enabled = true

  lifecycle_rules = {
    # The key of the map will be the lifecycle rule's name
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
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"

  notification_config = {
    destinations = {
      # The key of the map will be the destination's ARN
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
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

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
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"

  intelligent_tiering_archive_configurations = {
    # The key of the map will be the tiering rule's name

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
      filter = {
        prefix = "backup*"
      }

      access_tier           = "DEEP_ARCHIVE_ACCESS"
      days_until_transition = 90
    }
  }
}
```

#### Notes

- You must grant the necessary permissions to the source and destination bucket via bucket policy.
- [bucket permission][s3-inventory-bucket-permission]

### S3 Inventory

```terraform
module "s3_inventory_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"

  inventory_config = {
    # The key of the map will be the inventory rule's name

    # Daily inventory on backup
    "backup-daily-report" = {
      destination                = { bucket_arn = "arn:aws:s3:::psin-backup-inventory" }
      frequency                  = "Daily"
      additional_metadata_fields = ["Size", "LastModifiedDate", "StorageClass"]

      filter = {
        prefix = "backup*"
      }
    }
    # Weekly inventory on logs
    "log-weekly-report" = {
      destination = { bucket_arn = "arn:aws:s3:::psin-log-inventory" }
      frequency   = "Weekly"
    }
  }
}
```

### S3 Bucket Replication

```terraform
module "s3_bucket_replication_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"

  replication_config = {
    rules = {
      # The key of the map will be the replication rule's name

      # Replicate to bucket belonging to the same account, including encrypted objects
      "same-account-example" = {
        destination_bucket_arn = "arn:aws:s3:::psin-replication-dest"
        priority               = 0

        additional_replication_options = {
          replication_time_control_enabled  = true
          replication_metrics_enabled       = true
          replica_modification_sync_enabled = true
          delete_marker_replication_enabled = true
        }

        replicate_encrypted_objects = {
          kms_key_for_encrypting_destination_objects = "arn:aws:kms:us-east-2:111122223333:key/aaabbbccc-edac-44b6-81b6-29b58ae1bdfb"
        }
      }
      # Replicate to bucket belonging to another account
      "cross-account" = {
        destination_bucket_arn = "arn:aws:s3:::psin-replication-dest-777788889999"
        priority               = 1

        additional_replication_options = {
          delete_marker_replication_enabled = true
        }

        change_object_ownership_to_destination_bucket_owner = {
          destination_account_id = "777788889999"
        }
      }
    }
  }
}
```

### Enables Object Lock For New Bucket

```terraform
module "s3_bucket_object_lock_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name                = "demo-bucket"
  versioning_enabled  = true
  enables_object_lock = {}
}
```

### Enables Object Lock For Existing Bucket

```terraform
module "s3_bucket_object_lock_demo" {
  source = "github.com/FriendsOfTerraform/aws-s3.git?ref=v1.1.0"

  name = "demo-bucket"

  ##
  ## 1. Enables versioning. Doing so will generate an "Object lock token" in the back-end
  ##
  versioning_enabled = true

  ##
  ## 2. Contact AWS Support to provide you with the "Object Lock token" for the specified bucket and use the token to enables object lock
  ##
  enables_object_lock = {
    token = "NG2MKsfoLqV3A+aquXneSG4LOu/ekrlXkRXwIPFVfERT7XOPos+/k444d7RIH0E3W3p5"
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of the S3 bucket. Must be globally unique

    

    

    

    

    
**Since:** 1.0.0
        


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

Additional tags for the S3 bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">bucket_owner_account_id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The account ID of the expected bucket owner

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#corsconfigurations">CorsConfigurations</a>))</code></td>
    <td width="100%">cors_configurations</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [cross-origin resource sharing (CORS)][s3-cors]

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enablesobjectlock">EnablesObjectLock</a>)</code></td>
    <td width="100%">enables_object_lock</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [S3 Object Lock][s3-object-lock]. You must also set `versioning_enabled = true` to enable object lock.

    

    

    
**Examples:**
- [Enables Object Lock For New Bucket](#enables-object-lock-for-new-bucket)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#encryptionconfig">EncryptionConfig</a>)</code></td>
    <td width="100%">encryption_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [bucket level encryption][s3-encryption]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">force_destroy</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Force destroy of the bucket even if it is not empty

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#intelligenttieringarchiveconfigurations">IntelligentTieringArchiveConfigurations</a>))</code></td>
    <td width="100%">intelligent_tiering_archive_configurations</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures [S3 intelligent tiering][s3-intelligent-tiering].

    

    

    
**Examples:**
- [S3 Intelligent Tiering](#s3-intelligent-tiering)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#inventoryconfig">InventoryConfig</a>))</code></td>
    <td width="100%">inventory_config</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures [S3 inventory][s3-inventory].

    

    

    
**Examples:**
- [S3 Inventory](#s3-inventory)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#lifecyclerules">LifecycleRules</a>))</code></td>
    <td width="100%">lifecycle_rules</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [S3 lifecycle rules][s3-lifecycle].

    

    

    
**Examples:**
- [Lifecycle Rules](#lifecycle-rules)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#notificationconfig">NotificationConfig</a>)</code></td>
    <td width="100%">notification_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures S3 event notifications.

    

    

    
**Examples:**
- [S3 Event Notifications](#s3-event-notifications)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">object_ownership</td>
    <td><code>"BucketOwnerEnforced"</code></td>
</tr>
<tr><td colspan="3">

Control [ownership of objects][s3-object-ownership] written to this bucket from other AWS accounts and the use of access control lists (ACLs). Object ownership determines who can specify access to objects.

    
**Allowed Values:**
- `BucketOwnerEnforced`
- `BucketOwnerPreferred`
- `ObjectWriter`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Text of the S3 policy document to attach

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#publicaccessblock">PublicAccessBlock</a>)</code></td>
    <td width="100%">public_access_block</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures bucket to [block public access][public-access]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#replicationconfig">ReplicationConfig</a>)</code></td>
    <td width="100%">replication_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Manage [bucket replication][s3-bucket-replication].

    

    

    
**Examples:**
- [S3 Bucket Replication](#s3-bucket-replication)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">requester_pays_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [Requester Pays bucket][s3-requester-pays] so that the requester pays the cost of the request and data download instead of the bucket owner. Must also specify `bucket_owner_account_id`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#staticwebsitehostingconfig">StaticWebsiteHostingConfig</a>)</code></td>
    <td width="100%">static_website_hosting_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures [static website hosting][s3-static-website-hosting]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">transfer_acceleration_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [transfer acceleration][s3-transfer-acceleration]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">versioning_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [bucket versioning][s3-versioning]

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">bucket_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the S3 bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">bucket_domain_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Bucket domain name. Will be of format `bucketname.s3.amazonaws.com`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">bucket_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of the S3 bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">bucket_region</td>
    <td></td>
</tr>
<tr><td colspan="3">

AWS region this bucket resides in

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">website_domain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Domain of the website endpoint. This is used to create Route 53 alias records.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">website_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

Website endpoint.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### AdditionalReplicationOptions

Enables additional replication options

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">delete_marker_replication_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Delete markers created by S3 delete operations will be replicated. Delete markers created by lifecycle rules are not replicated.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">replica_modification_sync_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Replicate metadata changes made to replicas in this bucket to the destination bucket.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">replication_metrics_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

With replication metrics, you can monitor the total number and size of objects that are pending replication, and the maximum replication time to the destination Region. You can also view and diagnose replication failures.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">replication_time_control_enabled</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Replication Time Control replicates 99.99% of new objects within 15 minutes and includes replication metrics.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ChangeObjectOwnershipToDestinationBucketOwner

Specifies the overrides to use for object owners on replication. Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">destination_account_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Account ID to specify the replica ownership

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### CorsConfigurations



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">allowed_methods</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of HTTP methods that you allow the origin to execute.

    
**Allowed Values:**
- `GET`
- `PUT`
- `HEAD`
- `POST`
- `DELETE`

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allowed_origins</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the origins that you want to allow cross-domain requests from. The origin string can contain only one `*` wildcard character, such as `"http://*.example.com"`. You can optionally specify `"*"` as the origin to enable all the origins to send cross-origin requests. You can also specify `https` to enable only secure origins.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">allowed_headers</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify which headers are allowed in a preflight request through the Access-Control-Request-Headers header. Each header name in the Access-Control-Request-Headers header must match a corresponding entry in the element. Amazon S3 will send only the allowed headers in a response that were requested. Each header string can contain at most one `*` wildcard character. For example, `"x-amz-*"` will enable all Amazon-specific headers.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">expose_headers</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a list of headers in the response that you want customers to be able to access from their applications

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Unique identifier for the cors rule. The value cannot be longer than 255 characters.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_age_seconds</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the time in seconds that your browser can cache the response for a preflight request as identified by the resource, the HTTP method, and the origin.

    

    

    

    

    
**Since:** 1.1.0
        


</td></tr>
</tbody></table>



#### DefaultRetention

Configures default retention rule

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">retention_days</td>
    <td></td>
</tr>
<tr><td colspan="3">

Number of days the objects should be retained

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">retention_mode</td>
    <td></td>
</tr>
<tr><td colspan="3">

Default Object Lock retention mode you want to apply to new objects placed in the specified bucket.

    
**Allowed Values:**
- `COMPLIANCE`
- `GOVERNANCE`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Destination

Configures the destination where the report will be sent

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">account_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The account ID that owns the destination bucket. Must be set to ensure correct ownership of the report.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">bucket_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Destination bucket arn. The current bucket will be used if set to `null`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnablesObjectLock



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#defaultretention">DefaultRetention</a>)</code></td>
    <td width="100%">default_retention</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures default retention rule

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">token</td>
    <td></td>
</tr>
<tr><td colspan="3">

Token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's "Object Lock token." The token is generated in the back-end when versioning is enabled on a bucket.

    

    

    
**Examples:**
- [Enables Object Lock For Existing Bucket](#enables-object-lock-for-existing-bucket)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EncryptInventoryReport

Configures the type of server-side encryption to use to encrypt the inventory report

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the KMS customer master key (CMK) used to encrypt the inventory file. If left empty (`null`), `sse_s3` will be used for encryption

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EncryptionConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">bucket_key_enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables [S3 bucket key][s3-bucket-key] for encryption

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">use_kms_master_key</td>
    <td></td>
</tr>
<tr><td colspan="3">

CMK arn, encrypts bucket using `sse:kms`. If this is set to `null`, `sse:s3` will be used. e.g. `arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Expiration

Expiration configuration to expires current objects

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">clean_up_expired_object_delete_markers</td>
    <td></td>
</tr>
<tr><td colspan="3">

Permanently delete an object even if versioning is enabled

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">days_after_object_creation</td>
    <td></td>
</tr>
<tr><td colspan="3">

Expires objects after x days

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Filter

Limit the scope of this configuration using one or more filters

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">object_tags</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

All of these tags must exist in the object's tag set in order for the configuration to apply

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">prefix</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Object key name prefix that identifies the subset of objects to which the configuration applies

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### IntelligentTieringArchiveConfigurations



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">access_tier</td>
    <td></td>
</tr>
<tr><td colspan="3">

S3 Intelligent-Tiering access tier.

Restore time:

| Tier                | Expedited  | Standard        | Bulk
|---------------------|------------|-----------------|----------------
| Archive Access      | 1 - 5 mins | 3 - 5 hours     | 5 - 12 hours
| Deep Archive Access | N/A        | Within 12 hours | Within 48 hours

    
**Allowed Values:**
- `ARCHIVE_ACCESS`
- `DEEP_ARCHIVE_ACCESS`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">days_until_transition</td>
    <td></td>
</tr>
<tr><td colspan="3">

Number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#filter">Filter</a>)</code></td>
    <td width="100%">filter</td>
    <td></td>
</tr>
<tr><td colspan="3">

Limit the scope of this configuration using one or more filters

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### InventoryConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">frequency</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies how frequently inventory results are produced.

    
**Allowed Values:**
- `Daily`
- `Weekly`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">additional_metadata_fields</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of optional metadata to be included in the inventory results.

    
**Allowed Values:**
- `Size`
- `LastModifiedDate`
- `StorageClass`
- `ETag`
- `IsMultipartUploaded`
- `ReplicationStatus`
- `EncryptionStatus`
- `ObjectLockRetainUntilDate`
- `ObjectLockMode`
- `ObjectLockLegalHoldStatus`
- `IntelligentTieringAccessTier`
- `BucketKeyStatus`
- `ChecksumAlgorithm`
- `ObjectAccessControlList`
- `ObjectOwner`
- `LifecycleExpirationDate`

    

    

    
**Links:**
- [Available metadata field names](https://docs.aws.amazon.com/AmazonS3/latest/API/API_InventoryConfiguration.html#AmazonS3-Type-InventoryConfiguration-OptionalFields)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#destination">Destination</a>)</code></td>
    <td width="100%">destination</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the destination where the report will be sent

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#encryptinventoryreport">EncryptInventoryReport</a>)</code></td>
    <td width="100%">encrypt_inventory_report</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the type of server-side encryption to use to encrypt the inventory report

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#filter">Filter</a>)</code></td>
    <td width="100%">filter</td>
    <td></td>
</tr>
<tr><td colspan="3">

Limit the scope of this configuration using one or more filters

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">include_noncurrent_objects</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Specify if the report should include non current object versions

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">output_format</td>
    <td><code>"CSV"</code></td>
</tr>
<tr><td colspan="3">

Specifies the output format of the inventory results.

    
**Allowed Values:**
- `CSV`
- `ORC`
- `Parquet`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### LifecycleRules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">clean_up_incomplete_multipart_uploads_after</td>
    <td></td>
</tr>
<tr><td colspan="3">

Delete failed multipart uploads after x days

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#expiration">Expiration</a>)</code></td>
    <td width="100%">expiration</td>
    <td></td>
</tr>
<tr><td colspan="3">

Expiration configuration to expires current objects

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#filter">Filter</a>)</code></td>
    <td width="100%">filter</td>
    <td></td>
</tr>
<tr><td colspan="3">

Limit the scope of this configuration using one or more filters

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#noncurrentversionexpiration">NoncurrentVersionExpiration</a>)</code></td>
    <td width="100%">noncurrent_version_expiration</td>
    <td></td>
</tr>
<tr><td colspan="3">

Expiration configuration to expires noncurrent s3 objects

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#noncurrentversiontransitions">NoncurrentVersionTransitions</a>))</code></td>
    <td width="100%">noncurrent_version_transitions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transitions noncurrent s3 objects to other storage class.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(object(<a href="#transitions">Transitions</a>))</code></td>
    <td width="100%">transitions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transitions s3 objects to other storage class.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NoncurrentVersionExpiration

Expiration configuration to expires noncurrent s3 objects

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">days_after_objects_become_noncurrent</td>
    <td></td>
</tr>
<tr><td colspan="3">

Expires noncurrent objects after x days

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">number_of_newer_versions_to_retain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Number of noncurrent versions Amazon S3 will retain

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NoncurrentVersionTransitions

Transitions noncurrent s3 objects to other storage class.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">days_after_objects_become_noncurrent</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transition noncurrent objects after x days

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">storage_class</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the destination storage class.

    
**Allowed Values:**
- `ONEZONE_IA`
- `STANDARD_IA`
- `INTELLIGENT_TIERING`
- `GLACIER`
- `DEEP_ARCHIVE`
- `GLACIER_IR`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">number_of_newer_versions_to_retain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Number of noncurrent versions Amazon S3 will retain

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NotificationConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(list(object()))</code></td>
    <td width="100%">destinations</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of event notification in {destinationARN = [events]}. Supported AWS services include **Lambda**, **SQS**, and **SNS**. You can include up to one each **SQS** and **SNS** destination, but you can include multiple **Lambda** destinations.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PublicAccessBlock



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">block_public_acls</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether Amazon S3 should block public ACLs for this bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">block_public_policy</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether Amazon S3 should block public bucket policies for this bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">ignore_public_acls</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether Amazon S3 should ignore public ACLs for this bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">restrict_public_buckets</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether Amazon S3 should restrict public bucket policies for this bucket

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RedirectRequestsForAnObject

Configures a [webpage redirect][s3-webpage-redirect]. Mutually exclusive to `static_website`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">host_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of the host where requests are redirected

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td></td>
</tr>
<tr><td colspan="3">

Protocol to use when redirecting requests. The default is the protocol that is used in the original request.

    
**Allowed Values:**
- `http`
- `https`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ReplicateEncryptedObjects

Specifies whether encrypted objects will be replicated

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_for_encrypting_destination_objects</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) used to encrypt replicated objects

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ReplicationConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#rules">Rules</a>))</code></td>
    <td width="100%">rules</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures bucket replication rules. In {rule_name = replication_config} format

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the IAM role for Amazon S3 to assume when replicating the objects. One will be automatically generated by the module if this is left empty (`null`).

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">token</td>
    <td></td>
</tr>
<tr><td colspan="3">

Token to allow replication to be enabled on an Object Lock-enabled bucket. You must contact AWS support for the bucket's "Object Lock token."

    

    

    

    
**Links:**
- [Object lock overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-overview.html#object-lock-bucket-config)

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Rules

Configures bucket replication rules. In {rule_name = replication_config} format

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">destination_bucket_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the bucket where you want Amazon S3 to store the results

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

Priority associated with the rule. Priority must be unique between multiple rules.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#additionalreplicationoptions">AdditionalReplicationOptions</a>)</code></td>
    <td width="100%">additional_replication_options</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables additional replication options

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#changeobjectownershiptodestinationbucketowner">ChangeObjectOwnershipToDestinationBucketOwner</a>)</code></td>
    <td width="100%">change_object_ownership_to_destination_bucket_owner</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the overrides to use for object owners on replication. Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">destination_storage_class</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the destination storage class. Defaults to the same storage class of the source object

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#filter">Filter</a>)</code></td>
    <td width="100%">filter</td>
    <td></td>
</tr>
<tr><td colspan="3">

Limit the scope of this configuration using one or more filters

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#replicateencryptedobjects">ReplicateEncryptedObjects</a>)</code></td>
    <td width="100%">replicate_encrypted_objects</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies whether encrypted objects will be replicated

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### StaticWebsite

Manages documents S3 returns when a request is made to its web endpoint. Mutually exclusive to `redirect_requests_for_an_object`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">index_document</td>
    <td></td>
</tr>
<tr><td colspan="3">

Index document when requests are made to the root domain

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">error_document</td>
    <td></td>
</tr>
<tr><td colspan="3">

Document to return in case of a 4XX error

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### StaticWebsiteHostingConfig



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#redirectrequestsforanobject">RedirectRequestsForAnObject</a>)</code></td>
    <td width="100%">redirect_requests_for_an_object</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures a [webpage redirect][s3-webpage-redirect]. Mutually exclusive to `static_website`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#staticwebsite">StaticWebsite</a>)</code></td>
    <td width="100%">static_website</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages documents S3 returns when a request is made to its web endpoint. Mutually exclusive to `redirect_requests_for_an_object`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Transitions

Transitions s3 objects to other storage class.

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">days_after_object_creation</td>
    <td></td>
</tr>
<tr><td colspan="3">

Transition objects after x days

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">storage_class</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the destination storage class.

    
**Allowed Values:**
- `ONEZONE_IA`
- `STANDARD_IA`
- `INTELLIGENT_TIERING`
- `GLACIER`
- `DEEP_ARCHIVE`
- `GLACIER_IR`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[public-access]: https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html

[s3-bucket-key]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html

[s3-bucket-replication]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-what-is-isnot-replicated.html

[s3-cors]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/enabling-cors-examples.html?icmpid=docs_amazons3_console

[s3-encryption]: https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html

[s3-intelligent-tiering]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering.html

[s3-inventory]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-inventory.html

[s3-lifecycle]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html

[s3-object-lock]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html

[s3-object-ownership]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-new-bucket.html

[s3-requester-pays]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html

[s3-static-website-hosting]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html

[s3-transfer-acceleration]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html

[s3-versioning]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html

[s3-webpage-redirect]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html


<!-- TFDOCS_EXTRAS_END -->

[lambda-resource-based-policy]:https://docs.aws.amazon.com/lambda/latest/dg/access-control-resource-based.html
[s3-inventory-bucket-permission]:https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-s3-inventory-1
