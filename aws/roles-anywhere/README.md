# IAM Roles Anywhere Module

This module will build and configure an [AWS IAM Roles Anywhere][iam-roles-anywhere] by managing multiple trust anchors and profiles

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "rolesanywhere" {
  source = "github.com/FriendsOfTerraform/aws-roles-anywhere.git?ref=v1.0.0"

  # Manages multiple trust anchors
  trust_anchors = {
    # The key of the map will be the trust anchor's name
    "sales" = {
      certificate_authority_source = { external_certificate_bundle = file("${path.root}/sales_intermediate_ca.pem") }
    }
    "it" = {
      certificate_authority_source = { external_certificate_bundle = file("${path.root}/it_intermediate_ca.pem") }
    }
  }

  # Manages multiple profiles
  profiles = {
    # The key of the map will be the profile's name
    demo = {
      # Manages multiple IAM roles attached to the profile
      roles = {
        # The key of the map will be the role's name
        "it-application" = {
          attached_policy_arns = [
            "arn:aws:iam::aws:policy/AmazonS3FullAccess",
            "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
          ]

          # Contraints
          trust_anchor_name = "it"
          conditions = {
            "x509Subject/CN" = "instance-1"
            "x509Issuer/O"   = "MyCompany"
          }
        }

        "sales-application" = {
          attached_policy_arns = [
            "arn:aws:iam::aws:policy/AmazonS3FullAccess"
          ]

          # Contraints
          trust_anchor_name = "sales"
        }
      }
    }
  }
}
```

## Argument Reference

### Mandatory

- (map(object)) **`trust_anchors`** _[since v1.0.0]_

    Manages multiple [trust anchors][iam-roles-anywhere-trust-anchor]. A trust anchor refers to the trust relationship between Roles Anywhere and your Certificate Authority (CA). Certificates are used to authenticate against the trust anchor to obtain credentials for an IAM role.

    - (object) **`certificate_authority_source`** _[since v1.0.0]_

        Specify the source of trust (Certificate authority source)

        - (string) **`aws_private_certificate_authority_arn = null`** _[since v1.0.0]_

            The ARN of the Certificate authorities (CA) from AWS Certificate Manager in your account for this region. Mutually exclusive to `certificate_authority_source.external_certificate_bundle`

        - (string) **`external_certificate_bundle = null`** _[since v1.0.0]_

            Specify the PEM-encoded private CA certificate bundle. Mutually exclusive to `certificate_authority_source.aws_private_certificate_authority_arn`. The certificate must meet the following constrains:

            - The certificates MUST be `X.509v3`
            - The key usage MUST include `critical, keyCertSign, digitalSignature`, and OPTIONALLY `cRLSign`
            - Basic constraints MUST include `critical, CA:TRUE`
            - The signing algorithm MUST include `SHA256` or stronger. MD5 and SHA1 signing algorithms are rejected.

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the trust anchor

### Optional

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`profiles`** _[since v1.0.0]_

    Manages multiple [profiles][iam-roles-anywhere-profile]. Profiles are predefined sets of permissions that you can apply to roles that are used by workloads that authenticate with Roles Anywhere.

    - (map(object)) **`roles`** _[since v1.0.0]_

        Manages multiple roles that are attached to this profile

        - (list(string)) **`attached_policy_arns`** _[since v1.0.0]_

            A list of IAM policy ARNs to be attached to the individual role

        - (string) **`trust_anchor_name`** _[since v1.0.0]_

            Specify the name of the trust anchor this role constraints to. Valid values include only the trust anchors created by this module.

        - (map(string)) **`conditions = null`** _[since v1.0.0]_

            Specify conditions that further restrict which workloads may assume this role. Please see below for valid values:

            | Value           | Equates To                             | Example
            |-----------------|----------------------------------------|-----------------------------------
            | x509Subject/CN  | Subject's Common Name                  | "Instance1"
            | x509Issuer/C    | Issuer's Country                       | "US"
            | x509Issuer/O    | Issuer's Organization                  | "MyCompany"
            | x509Issuer/OU   | Issuer's Organization Unit             | "Sales"
            | x509Issuer/ST   | Issuer's State                         | "California"
            | x509Issuer/L    | Issuer's Location                      | "Los Angeles"
            | x509Issuer/CN   | Issuer's Common Name                   | "sales-intermediate-ca"
            | x509SAN/DNS     | Subject Alternative Name's DNS         | "Instance1.mycompany.com"
            | x509SAN/URI     | Subject Alternative Name's URI         | "spiffe://mycompany.com/Instance1"
            | x509SAN/Name/CN | Subject Alternative Name's Common Name | "Instance1"

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the profile

    - (bool) **`require_instance_properties = null`** _[since v1.0.0]_

        Specifies whether instance properties are required in CreateSession requests with this profile.

    - (number) **`session_duration_seconds = null`** _[since v1.0.0]_

        The number of seconds the vended session credentials are valid for. Defaults to `3600`.

    - (object) **`session_policy = null`** _[since v1.0.0]_

        Specify [IAM session policies][iam-session-policy] that apply to the vended session credentials

      - (string) **`inline_policy = null`** _[since v1.0.0]_

          Specify an inline JSON session policy document

      - (list(string)) **`managed_policy_arns = null`** _[since v1.0.0]_

          A list of managed policy ARNs that apply to the vended session credentials. You can specify `up to 10`.

## Outputs

- (map(string)) **`profile_arns`** _[since v1.0.0]_

    Map of ARNs of all profiles

- (map(string)) **`profile_ids`** _[since v1.0.0]_

    Map of IDs of all profiles

- (map(string)) **`trust_anchor_arns`** _[since v1.0.0]_

    Map of ARNs of all trust anchors

- (map(string)) **`trust_anchor_ids`** _[since v1.0.0]_

    Map of IDs of all trust anchors


[iam-roles-anywhere]:https://docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html
[iam-roles-anywhere-trust-anchor]:https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step1
[iam-roles-anywhere-profile]:https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step2
[iam-session-policy]:https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html#policies_session
