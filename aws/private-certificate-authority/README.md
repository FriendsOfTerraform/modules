# Private Certificate Authority Module

This module will build and configure an [AWS Private CA][private-ca] and its revocation methods

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
  - [Deploy Subordinate CA Signed By External Parent CA](#deploy-subordinate-ca-signed-by-external-parent-ca)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
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

<!-- TFDOCS_EXTRAS_START -->

## Inputs

### Required

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#subject">subject</a>)</code></td>
    <td width="100%">subject</td>
    <td></td>
</tr>
<tr><td colspan="3">

The X509 subject of the CA certificate

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

Additional tags for the private CA

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
    <td><code>bool</code></td>
    <td width="100%">authorize_acm_access_to_renew_certificates</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Grant AWS Certificate Manager (ACM) permissions for automated renewal for this CA at any time. The change will take effect for all future renewal cycles for ACM certificates generated within this account for this CA.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ca_type</td>
    <td><code>"ROOT"</code></td>
</tr>
<tr><td colspan="3">

Specify the type of the CA.

**Allowed Values:**

- `ROOT`
- `SUBORDINATE`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#crl_configuration">crl_configuration</a>)</code></td>
    <td width="100%">crl_configuration</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of the [certificate revocation list (CRL)][certificate-revocation-list] maintained by your private CA. A CRL is typically updated approximately 30 minutes after a certificate is revoked. If for any reason a CRL update fails, AWS Private CA makes further attempts every 15 minutes. CRL is distributed to a S3 bucket.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">key_algorithm</td>
    <td><code>"RSA_2048"</code></td>
</tr>
<tr><td colspan="3">

Type of the public key algorithm and size, in bits, of the key pair that your CA creates when it issues a certificate. When you create a subordinate CA, you must use a key algorithm supported by the parent CA.

**Allowed Values:**

- `RSA_2048`
- `RSA_4096`
- `EC_prime256v1`
- `EC_secp384r1`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#ocsp_configuration">ocsp_configuration</a>)</code></td>
    <td width="100%">ocsp_configuration</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration of [Online Certificate Status Protocol (OCSP)][online-certificate-status-protocol] support maintained by your private CA. When you revoke a certificate, OCSP responses may take up to 60 minutes to reflect the new status.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Attaches a JSON-formatted resource-based IAM policy to this private CA

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">signing_algorithm</td>
    <td><code>"SHA256WITHRSA"</code></td>
</tr>
<tr><td colspan="3">

Name of the algorithm your private CA uses to sign certificate requests.

| Key Algorithm               | Valid Signing Algorithm                           |
| --------------------------- | ------------------------------------------------- |
| RSA_2048, RSA_4096          | SHA256WITHRSA, SHA384WITHRSA, SHA512WITHRSA       |
| EC_prime256v1, EC_secp384r1 | SHA256WITHECDSA, SHA384WITHECDSA, SHA512WITHECDSA |

**Allowed Values:**

- `SHA256WITHECDSA`
- `SHA384WITHECDSA`
- `SHA512WITHECDSA`
- `SHA256WITHRSA`
- `SHA384WITHRSA`
- `SHA512WITHRSA`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>object(<a href="#subordinate_ca_configuration">subordinate_ca_configuration</a>)</code></td>
    <td width="100%">subordinate_ca_configuration</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify options to setup a subordinate CA. Required if `ca_type = "SUBORDINATE"`.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">usage_mode</td>
    <td><code>"GENERAL_PURPOSE"</code></td>
</tr>
<tr><td colspan="3">

Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly. Short-lived certificate validity is limited to seven days. Please refer to [this documentation][ca-mode] for more detail.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">validity</td>
    <td><code>"10 years"</code></td>
</tr>
<tr><td colspan="3">

Specify the validity period of the CA certificate.

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">certificate_authority_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the certificate authority

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">certificate_authority_certificate</td>
    <td></td>
</tr>
<tr><td colspan="3">

Base64-encoded certificate authority (CA) certificate. Only available after the certificate authority certificate has been imported.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">certificate_authority_certificate_chain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Base64-encoded certificate chain that includes any intermediate certificates and chains up to root on-premises certificate that you used to sign your private CA certificate. The chain does not include your private CA certificate. Only available after the certificate authority certificate has been imported.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">certificate_authority_csr</td>
    <td></td>
</tr>
<tr><td colspan="3">

The base64 PEM-encoded certificate signing request (CSR) for the private CA certificate.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">certificate_authority_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the certificate authority

**Since:** 1.0.0

</td></tr>
</tbody></table>

## Objects

#### create_s3_bucket

Create a new S3 bucket to use as the CRL Distribution Point (CDP). This bucket is publicly accessible with S3 Block Public Access disabled, as required by AWS Private CA. Alternatively, to leave BPA enabled (S3 best practice) do not use this setting to create the bucket but use [CloudFront with a private S3 bucket][crl-cloudfront]. Mutually exclusive to `s3_bucket_name`

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">bucket_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the S3 bucket. Must be globally unique.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags attached to the S3 bucket

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_versioning</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether S3 bucket versioning is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### crl_configuration

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#create_s3_bucket">create_s3_bucket</a>)</code></td>
    <td width="100%">create_s3_bucket</td>
    <td></td>
</tr>
<tr><td colspan="3">

Create a new S3 bucket to use as the CRL Distribution Point (CDP). This bucket is publicly accessible with S3 Block Public Access disabled, as required by AWS Private CA. Alternatively, to leave BPA enabled (S3 best practice) do not use this setting to create the bucket but use [CloudFront with a private S3 bucket][crl-cloudfront]. Mutually exclusive to `s3_bucket_name`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">custom_crl_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name inserted into the certificate CRL Distribution Points extension that enables the use of an alias for the CRL distribution point.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Specifies whether CRL is enabled

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">s3_bucket_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The S3 bucket where the CRLs are distributed to. Mutually exclusive to `create_s3_bucket`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">validity_in_days</td>
    <td><code>7</code></td>
</tr>
<tr><td colspan="3">

Validity period of the distributed CRLs in days

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### import_certificate

Import a subordinate CA certificate signed by an external CA. Mutually exclusive to `parent_ca_arn`

**Examples:**

- [Deploy Subordinate Ca Signed By External Parent Ca](#deploy-subordinate-ca-signed-by-external-parent-ca)

**Since:** 1.0.0

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">certificate</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the PEM-encoded subordinate CA certificate

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">certificate_chain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the PEM-encoded subordinate CA certificate chain

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### ocsp_configuration

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">custom_ocsp_endpoint</td>
    <td></td>
</tr>
<tr><td colspan="3">

CNAME specifying a customized OCSP domain. Note: The value of the CNAME must not include a protocol prefix such as "http://" or "https://". Please review [the documentation][online-certificate-status-protocol] for additional requirements to use the custom endpoint.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Specifies whether OCSP is enabled

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### subject

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">common_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the common name of the CA. For CA and end-entity certificates in a private PKI, the common name (CN) can be any string within the length limit

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">country</td>
    <td></td>
</tr>
<tr><td colspan="3">

Two-digit code that specifies the country in which the certificate subject located. For example: `"US"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">locality</td>
    <td></td>
</tr>
<tr><td colspan="3">

The locality (such as a city or town) in which the certificate subject is located. For example: `"Los Angeles"`

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">organization</td>
    <td></td>
</tr>
<tr><td colspan="3">

Legal name of the organization with which the certificate subject is affiliated.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">organization_unit</td>
    <td></td>
</tr>
<tr><td colspan="3">

A subdivision or unit of the organization (such as `"sales"` or `"finance"`) with which the certificate subject is affiliated.

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">state</td>
    <td></td>
</tr>
<tr><td colspan="3">

State in which the subject of the certificate is located. For example: `"California"`

**Since:** 1.0.0

</td></tr>
</tbody></table>

#### subordinate_ca_configuration

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#import_certificate">import_certificate</a>)</code></td>
    <td width="100%">import_certificate</td>
    <td></td>
</tr>
<tr><td colspan="3">

Import a subordinate CA certificate signed by an external CA. Mutually exclusive to `parent_ca_arn`

**Examples:**

- [Deploy Subordinate Ca Signed By External Parent Ca](#deploy-subordinate-ca-signed-by-external-parent-ca)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">parent_ca_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

Signs the subordinate CA certificate with an AWS private CA. Mutually exclusive to `import_certificate`

**Examples:**

- [Basic Usage](#basic-usage)

**Since:** 1.0.0

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">path_length</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

Specify the [path length constraint][path-length-constraint] of the subordinate CA, which determines the maximum number of lower-level subordinate CAs that can exist in a valid chain of trust. AWS Private CA supports a maximum chain of up to 5 levels deep, therefore this values must be `<= 3`

**Since:** 1.0.0

</td></tr>
</tbody></table>

[ca-mode]: https://docs.aws.amazon.com/privateca/latest/userguide/short-lived-certificates.html
[certificate-revocation-list]: https://docs.aws.amazon.com/privateca/latest/userguide/crl-planning.html
[crl-cloudfront]: https://docs.aws.amazon.com/privateca/latest/userguide/crl-planning.html#s3-bpa
[online-certificate-status-protocol]: https://docs.aws.amazon.com/privateca/latest/userguide/ocsp-customize.html
[path-length-constraint]: https://docs.aws.amazon.com/privateca/latest/userguide/ca-hierarchy.html#length-constraints

<!-- TFDOCS_EXTRAS_END -->

## Known Limitations

### Create New S3 Bucket For CRL

If you enable `crl_configuration` with the `create_s3_bucket` option, the creation could failed due to S3 not having the correct bucket policy created. This is because there is currently no way to configure the correct Terraform dependency to ensure the bucket policy gets created first. As a workaround, create the `crl_configuration` with `enabled = false`, this will allow the S3 bucket to be properly created, then update to `enabled = true`

[private-ca]: https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html
