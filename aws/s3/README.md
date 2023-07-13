# AWS S3 Module

This module will build an S3 bucket and allow various configurations such as static website and lifecycle rules.

## Table of Contents

- [Example Usage](#example-usage)
    - [Static Web Hosting](#static-web-hosting)
    - [Lifecycle Rules](#lifecycle-rules)
    - [S3 Event Notifications](#s3-event-notifications)
    - [Bucket Level Encryption](#bucket-level-encryption)
- [Argument Reference](#argument-reference)
- [Outputs](#outputs)

## Example Usage

### Static Web Hosting

This example uses a public read bucket policy to allow anonymous access to all objects in the bucket.

```terraform
module "static_web_hosting" {
    source = "github.com/CSUN-IT/TerraformModules.git/AWS/S3Bucket/v1.0"

    name = "demo-bucket-for-web-hosting"

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::demo-bucket-for-web-hosting/*"
        }
    }
    EOF

    static_web_hosting_config = {
        index_document = "index.html"
        error_document = "error.html"
    }
}
```

### Lifecycle Rules

This example shows a basic lifecycle rule to auto rotate logs that are tagged with “AutoRotate = true” that are saved in the “log/” path. After 30 days, the logs will be transitioned to the `STANDARD_IA` storage class, then to the `GLACIER` storage class after another 60 days. Finally, all logs will be expired (deleted) after another 90 days. Additionally, delete markers will be cleaned up, effectively making the deletion permanent if versoning is enabled. All previous versioned objects will be expired after 60 days.

```terraform
module "lifecycle_rule_demo" {
    source = "github.com/CSUN-IT/TerraformModules.git/AWS/S3Bucket/v1.0"

    name = "demo-bucket"
    versioning = true

    lifecycle_rules = {
        rotate-logs-rule = {
            prefix = "log/"

            tags = {
                AutoRotate = "true"
            }

            transitions = [
                {
                    days = 30
                    storage_class = "STANDARD_IA"
                },
                {
                    days = 90
                    storage_class = "GLACIER"
                }
            ]

            expiration = {
                days = 180
                clean_up_expired_object_delete_markers = true
            }

            noncurrent_version_expiration = {
                days = 60
            }
        }
    }
}
```

### S3 Event Notifications

This example configures the bucket to send notifications to a lambda function to process .jpg files uploaded into the “photo/” folder. It also configures the bucket to send notification to an SNS topic to notify administrators of all deletion events.

```terraform
locals {
    name = "demo-bucket"
    lambda_arn = "arn:aws:lambda:us-west-2:111122223333:function:ProcessPhotos",
    sns_arn = "arn:aws:sns:us-west-2:111122223333:Admins"
}

module "bucket_notification_demo" {
    source = "github.com/CSUN-IT/TerraformModules.git/AWS/S3Bucket/v1.0"

    name = local.name

    notification_config = {
        destinations = {
            local.lambda_arn = [{
                events = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
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

                # Don't apply filters, so it'll capture all objects that are being deleted
                filter_prefix = null
                filter_suffix = null
            }]
        }
    }
}
```

#### Notes
 
- You must ensure proper permissions are granted to S3 on each destination. Refers to the following documentations for more detail:
    - [Lambda Permission](https://github.com/CSUN-IT/TerraformModules/tree/master/AWS/LambdaFunction#grant-permission-to-other-aws-services)
    - [SNS Permission](#blank)
    - [SQS Permission](#blank)

### Bucket Level Encryption

```terraform
module "bucket_encryption_demo" {
    source = "github.com/CSUN-IT/TerraformModules.git/AWS/S3Bucket/v1.0"

    name = "demo-bucket"

    encryption_config = {
        enabled = true
        use_kms_master_key = "arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d"
    }
}
```

#### Notes

- This example enables bucket level encryption using SSE:KMS. To use SSE:S3 instead, set `use_kms_master_key` to null.

## Argument Reference

- (string) **`name`** _[since v1.0]_

  Name of the S3 bucket. Must be globally unique

- (map(string)|null) **`additional_tags = null`** _[since v1.0]_

  Additional tags for the S3 bucket

- (object|null) **`encryption_config = null`** _[since v1.0]_

  Configures [bucket level encryption][s3-encryption]

  ```terraform
  encryption_config = {
      enabled = true
      use_kms_master_key = "arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d"
  }
  ```
  
  - (bool) **`enabled`** _[since v1.0]_

    Enable server side encryption

  - (string|null) **`use_kms_master_key `** _[since v1.0]_

    CMK arn, encrypt bucket using sse:kms. If this is set to `null`, sse:s3 will be used. e.g. `arn:aws:kms:us-west-2:111122223333:key/6bfabcde-0d12-48ad-927f-48a805b2c62d`

- (bool) **`force_destroy = false`** _[since v1.0]_

    Force destroy non empty bucket

- (map(object)) **`lifecycle_rules = {}`** _[since v1.0]_

    Configures S3 lifecycle rules in {ruleName = ruleConfig}
    
    ```terraform
    bucket_lifecycle_rule = {
        expire_processed_photos = {
            prefix = "photo/"
            tags = {}
            clean_up_incomplete_multipart_uploads_after = 7
    
            expiration = {
                days = 180
                clean_up_expired_object_delete_markers = true
            }
        }
    }
    ```
    
    - (number) **`clean_up_incomplete_multipart_uploads_after`** _[since v1.0]_

        Delete failed multipart uploads after x days
    
    - (object) **`expiration`** _[since v1.0]_
    
        Expires s3 objects. Can include up to one
        
        - (bool) **`clean_up_expired_object_delete_markers`** _[since v1.0]_

            Permanently delete an object even if versioning is enabled
        
        - (number) **`days`** _[since v1.0]_
        
            Expires objects after x days
    
    - (object) **`noncurrent_version_expiration`** _[since v1.0]_
    
        Expires noncurrent s3 objects. Can include up to one
        
        - (number) **`days`** _[since v1.0]_
        
            Expires noncurrent objects after x days
    
    - (object) **`noncurrent_version_transition`** _[since v1.0]_
    
        Transitions noncurrent s3 objects to other storage class. Can include multiple
        
        - (number) **`days`** _[since v1.0]_

            Transition noncurrent objects after x days
        
        - (string) **`storage_class`** _[since v1.0]_
        
            Can be `ONEZONE_IA`, `STANDARD_IA`, `INTELLIGENT_TIERING`, `GLACIER`, or `DEEP_ARCHIVE`
    
    - (map(string)|null) **`prefix`** _[since v1.0]_
    
        Prefix of the s3 object keys to be included
    
    - (string|null) **`tags`** _[since v1.0]_
    
        Tags of the s3 objects to be included
    
    - (object) **`transition`** _[since v1.0]_
    
        Transitions s3 objects to other storage class. Can include multiple
        
        - (number) **`days`** _[since v1.0]_

            Transition objects after x days
        
        - (string) **`storage_class`** _[since v1.0]_
        
            Can be `ONEZONE_IA`, `STANDARD_IA`, `INTELLIGENT_TIERING`, `GLACIER`, or `DEEP_ARCHIVE`

- (object|null) **`notification_config = null`** _[since v1.0]_

    Configures S3 event notifiactions
    
    ```terraform
    notification_config = {
        destinations = {
            "arn:aws:lambda:us-west-2:111122223333:function:ProcessPhotos" = [{
                events: ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
                filter_prefix: "photo/"
                filter_suffix: ".jpg"
            }]
        }
    }
    ```
    
    - (map(list(object))) **`destinations`** _[since v2.0]_ ([view v1.0 documentation](https://github.com/CSUN-IT/TerraformModules/blob/6fb02406774c503af652ba907b59d46518dd2d37/AWS/S3Bucket/README.md#argument-reference))

        Map of event notification in {destinationARN = event}. Supported AWS services include **Lambda**, **SQS**, and **SNS**. You can include up to one each **SQS** and **SNS** destination, but you can include multiple **Lambda** destinations.
        
        - (list(string)) **`events`** _[since v1.0]_

            [Events][s3-event] to listen to
        
        - (string|null) **`filter_prefix`** _[since v1.0]_
        
            Filters objects by key name prefix
        
        - (string|null) **`filter_suffix`** _[since v1.0]_
        
            Filters objects by key name suffix

- (string|null) **`policy = null`** _[since v1.0]_

    Attach bucket policy

- (object|null) **`public_access_block = null`** _[since v1.0]_

    Configures bucket to [block public access][public-access]
    
    ```terraform
    public_access_block = {
        block_public_acls = true
        block_public_policy = true
        ignore_public_acls = true
        restrict_public_buckets = true
    }
    ```
    
    - (bool) **`block_public_acls`** _[since v1.0]_

        Whether Amazon S3 should block public ACLs for this bucket
    
    - (bool) **`block_public_policy`** _[since v1.0]_
    
        Whether Amazon S3 should block public bucket policies for this bucket
    
    - (bool) **`ignore_public_acls`** _[since v1.0]_
    
        Whether Amazon S3 should ignore public ACLs for this bucket
    
    - (bool) **`restrict_public_buckets`** _[since v1.0]_
    
        Whether Amazon S3 should restrict public bucket policies for this bucket

- (object|null) **`static_web_hosting_config = null`** _[since v1.0]_

    Enable static web hosting
    
    ```terraform
    static_web_hosting_config = {
        index_document = "index.html"
        error_document = "error.html"
    }
    ```
    
    - (string) **`error_document`** _[since v1.0]_

        Document to return in case of a 4XX error
    
    - (string) **`index_document`** _[since v1.0]_
    
        Index document when requests are made to the root domain

- (bool) **`versioning = false`** _[since v1.0]_

    Enable versioning. Can only be suspended after enabled

[bucket-policy]:https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html
[public-access]:https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html
[s3-encryption]:https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
[s3-event]:https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations

## Outputs

- (string) **`name`** _[since v1.0]_

    Name of the created S3 bucket

- (string) **`bucket_arn`** _[since v1.0]_

    ARN of the created S3 bucket

- (string) **`bucket_web_url`** _[since v1.0]_

    Static website URL. Blank if static web hosting is not enabled
