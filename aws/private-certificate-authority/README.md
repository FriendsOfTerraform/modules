# Private Certificate Authority Module

This module will build and configure an [AWS Private CA][private-ca] and its revocation methods

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Deploy Subordinate CA Signed By External Parent CA](#deploy-subordinate-ca-signed-by-external-parent-ca)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
    - [Create New S3 Bucket For CRL](#create-new-s3-bucket-for-crl)

## Example Usage

### Basic Usage

```terraform
# Create Root CA
module "root_ca" {
  source = "github.com/FriendsOfTerraform/aws-private-certificate-authority.git?ref=v1.0.0"

  # The X509 subject for the CA
  subject = {
    common_name       = "demo-root-ca"
    country           = "US"
    locality          = "Los Angeles"
    organization      = "My Company"
    organization_unit = "Cloud"
    state             = "California"
  }

  # Enables CRL distribution
  crl_configuration = {
    enabled = true

    create_s3_bucket = {
      bucket_name = "root-ca-crl"
    }
  }

  # Enables OCSP
  ocsp_configuration = {
    enabled = true
  }
}

module "roles_anywhere_intermediate_ca" {
  source = "github.com/FriendsOfTerraform/aws-private-certificate-authority.git?ref=v1.0.0"

  ca_type    = "SUBORDINATE"
  usage_mode = "SHORT_LIVED_CERTIFICATE"
  validity   = "5 years"

  # Sign subordinate CA with root CA
  subordinate_ca_configuration = {
    parent_ca_arn = module.root_ca.certificate_authority_arn
  }

  # The X509 subject for the Subordinate CA
  subject = {
    common_name       = "roles-anywhere-intermediate-ca"
    country           = "US"
    locality          = "Los Angeles"
    organization      = "My Company"
    organization_unit = "Cloud"
    state             = "California"
  }
}
```

### Deploy Subordinate CA Signed By External Parent CA

1. Create the subordinate CA and obtain its CSR

```terraform
module "external_intermediate_ca" {
  source = "github.com/FriendsOfTerraform/aws-private-certificate-authority.git?ref=v1.0.0"

  ca_type    = "SUBORDINATE"
  usage_mode = "SHORT_LIVED_CERTIFICATE"
  validity   = "5 years"

  subject = {
    common_name       = "external-intermediate-ca"
    country           = "US"
    locality          = "Los Angeles"
    organization      = "My Company"
    organization_unit = "Cloud"
    state             = "California"
  }
}

# output CSR
output "external_intermediate_ca_csr" {
  value = module.external_intermediate_ca.certificate_authority_csr
}
```

2. After signing the CSR with the external parent CA, update the manifest to import the certificate as follow

```terraform
module "external_intermediate_ca" {
  source = "github.com/FriendsOfTerraform/aws-private-certificate-authority.git?ref=v1.0.0"

  ca_type    = "SUBORDINATE"
  usage_mode = "SHORT_LIVED_CERTIFICATE"
  validity   = "5 years"

  # import subordinate CA certificate
  subordinate_ca_configuration = {
    import_certificate = {
      certificate       = file("${path.root}/certificate.pem")
      certificate_chain = file("${path.root}/certificate-chain.pem")
    }
  }

  subject = {
    common_name       = "external-intermediate-ca"
    country           = "US"
    locality          = "Los Angeles"
    organization      = "My Company"
    organization_unit = "Cloud"
    state             = "California"
  }
}
```

## Argument Reference

### Mandatory

- (object) **`subject`** _[since v1.0.0]_

    The X509 subject of the CA certificate

    - (string) **`common_name`** _[since v1.0.0]_

        Specify the common name of the CA. For CA and end-entity certificates in a private PKI, the common name (CN) can be any string within the length limit

    - (optional(string)) **`country = null`** _[since v1.0.0]_

        Two-digit code that specifies the country in which the certificate subject located. For example: `"US"`

    - (optional(string)) **`locality = null`** _[since v1.0.0]_

        The locality (such as a city or town) in which the certificate subject is located. For example: `"Los Angeles"`

    - (optional(string)) **`organization = null`** _[since v1.0.0]_

        Legal name of the organization with which the certificate subject is affiliated.

    - (optional(string)) **`organization_unit = null`** _[since v1.0.0]_

        A subdivision or unit of the organization (such as `"sales"` or `"finance"`) with which the certificate subject is affiliated.

    - (optional(string)) **`state`** _[since v1.0.0]_

        State in which the subject of the certificate is located. For example: `"California"`

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the private CA

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (bool) **`authorize_acm_access_to_renew_certificates = true`** _[since v1.0.0]_

    Grant AWS Certificate Manager (ACM) permissions for automated renewal for this CA at any time. The change will take effect for all future renewal cycles for ACM certificates generated within this account for this CA.

- (string) **`ca_type = "ROOT"`** _[since v1.0.0]_

    Specify the type of the CA. Valid values are: `"ROOT"`, `"SUBORDINATE"`

- (object) **`crl_configuration = null`** _[since v1.0.0]_

    Configuration of the [certificate revocation list (CRL)][certificate-revocation-list] maintained by your private CA. A CRL is typically updated approximately 30 minutes after a certificate is revoked. If for any reason a CRL update fails, AWS Private CA makes further attempts every 15 minutes. CRL is distributed to a S3 bucket.

    - (object) **`create_s3_bucket = null`** _[since v1.0.0]_

        Create a new S3 bucket to use as the CRL Distribution Point (CDP). This bucket is publicly accessible with S3 Block Public Access disabled, as required by AWS Private CA. Alternatively, to leave BPA enabled (S3 best practice) do not use this setting to create the bucket but use [CloudFront with a private S3 bucket][crl-cloudfront]. Mutually exclusive to `s3_bucket_name`

        - (string) **`bucket_name`** _[since v1.0.0]_

            The name of the S3 bucket. Must be globally unique.

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags attached to the S3 bucket

        - (bool) **`enable_versioning = false`** _[since v1.0.0]_

            Whether S3 bucket versioning is enabled

    - (string) **`custom_crl_name = null`** _[since v1.0.0]_

        Name inserted into the certificate CRL Distribution Points extension that enables the use of an alias for the CRL distribution point.

    - (bool) **`enabled = true`** _[since v1.0.0]_

        Specifies whether CRL is enabled

    - (string) **`s3_bucket_name = null`** _[since v1.0.0]_

        The S3 bucket where the CRLs are distributed to. Mutually exclusive to `create_s3_bucket`

    - (number) **`validity_in_days = 7`** _[since v1.0.0]_

        Validity period of the distributed CRLs in days

- (string) **`key_algorithm = "RSA_2048"`** _[since v1.0.0]_

    Type of the public key algorithm and size, in bits, of the key pair that your CA creates when it issues a certificate. When you create a subordinate CA, you must use a key algorithm supported by the parent CA. Valid values: `"RSA_2048"`, `"RSA_4096"`, `"EC_prime256v1"`, `"EC_secp384r1"`

- (object) **`ocsp_configuration = null`** _[since v1.0.0]_

    Configuration of [Online Certificate Status Protocol (OCSP)][online-certificate-status-protocol] support maintained by your private CA. When you revoke a certificate, OCSP responses may take up to 60 minutes to reflect the new status.

    - (string) **`custom_ocsp_endpoint = null`** _[since v1.0.0]_

        CNAME specifying a customized OCSP domain. Note: The value of the CNAME must not include a protocol prefix such as "http://" or "https://". Please review [the documentation][online-certificate-status-protocol] for additional requirements to use the custom endpoint.

    - (bool) **`enabled = true`** _[since v1.0.0]_

        Specifies whether OCSP is enabled

- (string) **`policy = null`** _[since v1.0.0]_

    Attaches a JSON-formatted resource-based IAM policy to this private CA

- (string) **`signing_algorithm = "SHA256WITHRSA"`** _[since v1.0.0]_

    Name of the algorithm your private CA uses to sign certificate requests. Valid values: `"SHA256WITHECDSA"`, `"SHA384WITHECDSA"`, `"SHA512WITHECDSA"`, `"SHA256WITHRSA"`, `"SHA384WITHRSA"`, `"SHA512WITHRSA"`

    | Key Algorithm               | Valid Signing Algorithm
    |-----------------------------|--------------------------------------------------
    | RSA_2048, RSA_4096          | SHA256WITHRSA, SHA384WITHRSA, SHA512WITHRSA
    | EC_prime256v1, EC_secp384r1 | SHA256WITHECDSA, SHA384WITHECDSA, SHA512WITHECDSA

- (object) **`subordinate_ca_configuration = null`** _[since v1.0.0]_

    Specify options to setup a subordinate CA. Required if `ca_type = "SUBORDINATE"`.

    - (object) **`import_certificate = null`** _[since v1.0.0]_

        Import a subordinate CA certificate signed by an external CA. [See example](#deploy-subordinate-ca-signed-by-external-parent-ca). Mutually exclusive to `parent_ca_arn`

      - (string) **`certificate`** _[since v1.0.0]_

          Specify the PEM-encoded subordinate CA certificate

      - (string) **`certificate_chain`** _[since v1.0.0]_

          Specify the PEM-encoded subordinate CA certificate chain

    - (string) **`parent_ca_arn = null`** _[since v1.0.0]_

        Signs the subordinate CA certificate with an AWS private CA. [See example](#basic-usage). Mutually exclusive to `import_certificate`

    - (number) **`path_length = 0`** _[since v1.0.0]_

        Specify the [path length constraint][path-length-contraint] of the subordinate CA, which determines the maximum number of lower-level subordinate CAs that can exist in a valid chain of trust. AWS Private CA supports a maximum chain of up to 5 levels deep, therefore this values must be `<= 3`

- (string) **`usage_mode = "GENERAL_PURPOSE"`** _[since v1.0.0]_

    Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly. Short-lived certificate validity is limited to seven days. Please refer to [this documentation][ca-mode] for more detail.

- (string) **`validity = "10 years"`** _[since v1.0.0]_

    Specify the validity period of the CA certificate. [See example](#basic-usage)

## Outputs

- (string) **`certificate_authority_arn`** _[since v1.0.0]_

    The ARN of the certificate authority

- (string) **`certificate_authority_certificate`** _[since v1.0.0]_

    Base64-encoded certificate authority (CA) certificate. Only available after the certificate authority certificate has been imported.

- (string) **`certificate_authority_csr`** _[since v1.0.0]_

    The base64 PEM-encoded certificate signing request (CSR) for the private CA certificate.

- (string) **`certificate_authority_certificate_chain`** _[since v1.0.0]_

    Base64-encoded certificate chain that includes any intermediate certificates and chains up to root on-premises certificate that you used to sign your private CA certificate. The chain does not include your private CA certificate. Only available after the certificate authority certificate has been imported.

- (string) **`certificate_authority_id`** _[since v1.0.0]_

    The ID of the certificate authority

## Known Limitations

### Create New S3 Bucket For CRL

If you enable `crl_configuration` with the `create_s3_bucket` option, the creation could failed due to S3 not having the correct bucket policy created. This is because there is currently no way to configure the correct Terraform dependency to ensure the bucket policy gets created first. As a workaround, create the `crl_configuration` with `enabled = false`, this will allow the S3 bucket to be properly created, then update to `enabled = true`

[ca-mode]:https://docs.aws.amazon.com/privateca/latest/userguide/short-lived-certificates.html
[certificate-revocation-list]:https://docs.aws.amazon.com/privateca/latest/userguide/crl-planning.html
[crl-cloudfront]:https://docs.aws.amazon.com/privateca/latest/userguide/crl-planning.html#s3-bpa
[online-certificate-status-protocol]:https://docs.aws.amazon.com/privateca/latest/userguide/ocsp-customize.html
[path-length-contraint]:https://docs.aws.amazon.com/privateca/latest/userguide/ca-hierarchy.html#length-constraints
[private-ca]:https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html
