# Certificate Module

This module manages multiple certificates in [Certificate Manager](https://aws.amazon.com/acm/)

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-acm.git?ref=v1.0.0"

  # Manages multiple public certificates
  # The keys of the map are the FQDN of the certificate
  public_certificates = {
    "psin-lab.demo.com"           = {}
    "psin-lab-with-sans.demo.com" = { subject_alternative_names = ["psin-lab-with-sans2.demo.com"] }
  }
}
```

## Argument Reference

### Optional

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`public_certificates = {}`** _[since v1.0.0]_

    Manage multiple public SSL/TLS certificates from Amazon. By default, public certificates are trusted by browsers and operating systems. Please [see example](#basic-usage)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags associated with the certificate

    - (bool) **`allow_export = false`** _[since v1.0.0]_

        If enabled, you can export your ACM public certificate's private key. You can use the certificate for different workloads like in the AWS Cloud, on-premises, and hybrid.

    - (string) **`key_algorithm = "RSA_2048"`** _[since v1.0.0]_

        The encryption algorithm. Some algorithms may not be supported by all AWS services. Valid values: `"RSA_2048"`, `"EC_prime256v1"`, `"EC_secp384r1"`

    - (list(string)) **`subject_alternative_names = []`** _[since v1.0.0]_

        List of additional names for this certificate

    - (string) **`validation_method = "DNS"`** _[since v1.0.0]_

        Method for validating domain ownership. Valid values: `"DNS"`, `"EMAIL"`. Please refer to [this documentation][acm-domain-ownership-validation] for more information

## Outputs

- (map(object)) **`public_certificates`** _[since v1.0.0]_

    Information of all the public certificates managed by this module

    - (string) **`arn`** _[since v1.0.0]_

        ARN of the certificate

    - (list(object)) **`domain_validation_options`** _[since v1.0.0]_

        Set of domain validation objects which can be used to complete certificate validation.

    - (string) **`id`** _[since v1.0.0]_

        ARN of the certificate

    - (string) **`not_after`** _[since v1.0.0]_

        Expiration date and time of the certificate.

    - (string) **`not_before`** _[since v1.0.0]_

        Start of the validity period of the certificate.

    - (string) **`renewal_eligibility`** _[since v1.0.0]_

        Whether the certificate is eligible for managed renewal.

    - (list(string)) **`renewal_summary`** _[since v1.0.0]_

        Contains information about the status of ACM's managed renewal for the certificate.

    - (string) **`status`** _[since v1.0.0]_

        Status of the certificate.

    - (list(string)) **`validation_emails`** _[since v1.0.0]_

        List of addresses that received a validation email. Only set if EMAIL validation was used.

[acm-domain-ownership-validation]:https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html
