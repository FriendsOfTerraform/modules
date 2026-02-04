# Certificate Module

This module manages multiple certificates in [Certificate Manager](https://aws.amazon.com/acm/)

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required

_No required inputs._


### Optional












<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
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
    <td><code>map(object(<a href="#publiccertificates">PublicCertificates</a>))</code></td>
    <td width="100%">public_certificates</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manage multiple public SSL/TLS certificates from Amazon. By default, public
certificates are trusted by browsers and operating systems.






**Examples:**
- [Basic Usage](#basic-usage)




**Since:** 1.0.0



</td></tr>
</tbody></table>

## Outputs












<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#publiccertificates">PublicCertificates</a>))</code></td>
    <td width="100%">public_certificates</td>
    <td></td>
</tr>
<tr><td colspan="3">

Information of all the public certificates managed by this module










**Since:** 1.0.0



</td></tr>
</tbody></table>

## Objects



#### PublicCertificates












<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the certificate










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>list(object)</code></td>
    <td width="100%">domain_validation_options</td>
    <td></td>
</tr>
<tr><td colspan="3">

Set of domain validation objects which can be used to complete certificate validation.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the certificate










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">not_after</td>
    <td></td>
</tr>
<tr><td colspan="3">

Expiration date and time of the certificate










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">not_before</td>
    <td></td>
</tr>
<tr><td colspan="3">

Start of the validity period of the certificate.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">renewal_eligibility</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether the certificate is eligible for managed renewal.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">renewal_summary</td>
    <td></td>
</tr>
<tr><td colspan="3">

Contains information about the status of ACM's managed renewal for the certificate.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">status</td>
    <td></td>
</tr>
<tr><td colspan="3">

Status of the certificate.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">validation_emails</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of addresses that received a validation email. Only set if EMAIL validation was used.










**Since:** 1.0.0



</td></tr>
</tbody></table>





<!-- TFDOCS_EXTRAS_END -->

[acm-domain-ownership-validation]:https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html
