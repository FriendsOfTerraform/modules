# Resource Access Manager Module

This module creates and configures a [Resource Access Manager](https://aws.amazon.com/ram/) share to allow sharing supported resources to other AWS accounts

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
- [Known Limitations](#known-limitations)
    - [shared resources have empty name](#shared-resources-have-empty-name)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-resource-access-manager.git?ref=v1.0.0"

  name = "demo-share"

  # You can add multiple principals of different types
  principals = [
    "111122223333",                                                         # AWS account ID
    "arn:aws:organizations::123456789012:organization/o-1234567abc",        # AWS Organization
    "arn:aws:organizations::123456789012:ou/o-1234567abc/ou-a123-b4567890", # AWS Organization's OU
    "arn:aws:iam::111122223333:role/demo-role"                              # IAM role
  ]

  # You can share multiple supported resources of different types
  resources = [
    "arn:aws:ec2:us-east-1:129876543210:transit-gateway/tgw-04387512345abcdef", # transit gateway
    "arn:aws:ec2:us-east-1:129876543210:subnet/subnet-123456963fabcdef"         # VPC subnet
  ]

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

The name of the resource share. All associated resources will also have their name prefixed with this value










**Since:** 1.0.0



</td></tr>
</tbody></table>


### Optional












<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">accept_sharings</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of share ARNs to accept sharing from










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the resource share










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
    <td width="100%">allow_external_principals</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

If enabled, you can share resources with any AWS accounts, roles, and users. If you are in an organization, you can also share with the entire organization or organizational units in that organization.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">principals</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of principals to grant access of the resources to. Valid values include: `the 12-digits AWS account ID, ARN of an AWS Organization, AWS Organization's OU, IAM role, IAM user, or a Service principal`.










**Since:** 1.0.0



</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">resources</td>
    <td><code>[]</code></td>
</tr>
<tr><td colspan="3">

List of ARNs of supported resources to share. Please refer to [this documentation][ram-shareable-resources] for a list of shareable resources.










**Since:** 1.0.0



</td></tr>
</tbody></table>

## Outputs












<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_share_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ID of the resource share










**Since:** 1.0.0



</td></tr>
</tbody></table>

## Objects




[ram-shareable-resources]: https://docs.aws.amazon.com/ram/latest/userguide/shareable.html


<!-- TFDOCS_EXTRAS_END -->

## Known Limitations

### shared resources have empty name

The name of the shared resources do not get carried over to the remote accounts, and must manually updated as necessary.
