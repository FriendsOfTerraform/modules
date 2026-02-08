# IAM Roles Anywhere Module

This module will build and configure [AWS IAM Roles Anywhere][iam-roles-anywhere] by managing multiple trust anchors and profiles

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
module "rolesanywhere" {
  source = "github.com/FriendsOfTerraform/aws-roles-anywhere.git?ref=v1.0.1"

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
          # You can only specify trust anchor that is managed by this module
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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#trustanchors">TrustAnchors</a>))</code></td>
    <td width="100%">trust_anchors</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages multiple [trust anchors][iam-roles-anywhere-trust-anchor]. A trust anchor refers to the trust relationship between Roles Anywhere and your Certificate Authority (CA). Certificates are used to authenticate against the trust anchor to obtain credentials for an IAM role.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
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
    <td><code>map(object(<a href="#profiles">Profiles</a>))</code></td>
    <td width="100%">profiles</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Manages multiple [profiles][iam-roles-anywhere-profile]. Profiles are predefined sets of permissions that you can apply to roles that are used by workloads that authenticate with Roles Anywhere.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">profile_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of ARNs of all profiles

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">profile_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of IDs of all profiles

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">trust_anchor_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of ARNs of all trust anchors

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">trust_anchor_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

Map of IDs of all trust anchors

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### CertificateAuthoritySource

Specify the source of trust (Certificate authority source)

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">aws_private_certificate_authority_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the Certificate authorities (CA) from AWS Certificate Manager in your account for this region. Mutually exclusive to `external_certificate_bundle`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">external_certificate_bundle</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the PEM-encoded private CA certificate bundle. Mutually exclusive to `aws_private_certificate_authority_arn`. The certificate must meet the following constrains:

- The certificates MUST be `X.509v3`
- The key usage MUST include `critical, keyCertSign, digitalSignature`, and OPTIONALLY `cRLSign`
- Basic constraints MUST include `critical, CA:TRUE`
- The signing algorithm MUST include `SHA256` or stronger. MD5 and SHA1 signing algorithms are rejected.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Profiles



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#roles">Roles</a>))</code></td>
    <td width="100%">roles</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manages multiple IAM roles that are attached to this profile

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the profile

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">require_instance_properties</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies whether instance properties are required in CreateSession requests with this profile.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">session_duration_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

The number of seconds the vended session credentials are valid for. Defaults to `3600`.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#sessionpolicy">SessionPolicy</a>)</code></td>
    <td width="100%">session_policy</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify [IAM session policies][iam-session-policy] that apply to the vended session credentials

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Roles

Manages multiple IAM roles that are attached to this profile

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">attached_policy_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of IAM policy ARNs to be attached to the individual role

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">trust_anchor_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the trust anchor this role constraints to. Valid values include only the trust anchors created by this module.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">conditions</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify conditions that further restrict which workloads may assume this role. Please see below for valid values:

| Value           | Equates To                             | Example
|-----------------|----------------------------------------|-----------------------------------
| x509Subject/CN  | Subject's Common Name                  | "instance1"
| x509Issuer/C    | Issuer's Country                       | "US"
| x509Issuer/O    | Issuer's Organization                  | "MyCompany"
| x509Issuer/OU   | Issuer's Organization Unit             | "Sales"
| x509Issuer/ST   | Issuer's State                         | "California"
| x509Issuer/L    | Issuer's Location                      | "Los Angeles"
| x509Issuer/CN   | Issuer's Common Name                   | "sales-intermediate-ca"
| x509SAN/DNS     | Subject Alternative Name's DNS         | "instance1.mycompany.com"
| x509SAN/URI     | Subject Alternative Name's URI         | "spiffe://mycompany.com/instance1"
| x509SAN/Name/CN | Subject Alternative Name's Common Name | "instance1"

    
**Allowed Values:**
- `x509Subject/CN`
- `x509Issuer/C`
- `x509Issuer/O`
- `x509Issuer/OU`
- `x509Issuer/ST`
- `x509Issuer/L`
- `x509Issuer/CN`
- `x509SAN/DNS`
- `x509SAN/URI`
- `x509SAN/Name/CN`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">permissions_boundary</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the ARN of the policy that is used to set the permissions boundary for the role.

    

    

    

    

    
**Since:** 1.0.1
        


</td></tr>
</tbody></table>



#### SessionPolicy

Specify [IAM session policies][iam-session-policy] that apply to the vended session credentials

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">inline_policy</td>
    <td></td>
</tr>
<tr><td colspan="3">

An inline JSON session policy document

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">managed_policy_arns</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of `up to 10` managed policy ARNs that apply to the vended session credentials.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### TrustAnchors



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#certificateauthoritysource">CertificateAuthoritySource</a>)</code></td>
    <td width="100%">certificate_authority_source</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the source of trust (Certificate authority source)

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the trust anchor

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[iam-roles-anywhere-profile]: https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step2

[iam-roles-anywhere-trust-anchor]: https://docs.aws.amazon.com/rolesanywhere/latest/userguide/getting-started.html#getting-started-step1

[iam-session-policy]: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html#policies_session


<!-- TFDOCS_EXTRAS_END -->

[iam-roles-anywhere]:https://docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html
