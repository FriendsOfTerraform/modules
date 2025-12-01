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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        </tbody></table>

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

### Objects



#### PublicCertificates



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags associated with the certificate

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_export</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled, you can export your ACM public certificate's private key.
You can use the certificate for different workloads like in the AWS Cloud,
on-premises, and hybrid.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">key_algorithm</td>
    <td><code>"RSA_2048"</code></td>
</tr>
<tr><td colspan="3">

The encryption algorithm. Some algorithms may not be supported by all
AWS services.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subject_alternative_names</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

List of additional names for this certificate

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">validation_method</td>
    <td><code>"DNS"</code></td>
</tr>
<tr><td colspan="3">

Method for validating domain ownership.

    

    
**Links:**
- [Domain Ownership Validation](https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html)

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>





<!-- TFDOCS_EXTRAS_END -->

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
