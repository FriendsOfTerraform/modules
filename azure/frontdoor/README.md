# Azure Front Door Module

This module will create and configure an Azure Front Door and allow you to manage its resources such as origins, endpoints, and routes

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)
- [Notes](#notes)

## Example Usage

### Basic Usage

This example creates an Azure Front Door profile with an origin group named `demo-webapp` with two origins. Then creates an endpoint named `default` and route named `webapp` to route traffic to origins behind `demo-webapp`

```terraform
module "Front Door" {
  source = "github.com/FriendsOfTerraform/azure-frontdoor.git?ref=v0.0.1"

  azure = {
    resource_group_name = "aks-dev"
  }

  name = "Front Door-demo"

  origin_groups = {
    "demo-webapp" = {
      health_probe             = {}
      session_affinity_enabled = false

      origins = {
        webapp-uswest = {
          hostname = "webapp-petersin.azurewebsites.net"
        }
        webapp-useast = {
          hostname = "petersin-webapp-useast.azurewebsites.net"
        }
      }
    }
  }

  endpoints = {
    "default" = {
      routes = {
        webapp = {
          # must defines an origin group that is created by the same module
          origin_group_name = "demo-webapp"
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
    <td><code>object(<a href="#azure">Azure</a>)</code></td>
    <td width="100%">azure</td>
    <td></td>
</tr>
<tr><td colspan="3">

The resource group name and the location where the resources will be deployed to

```terraform
azure = {
resource_group_name = "sandbox"
location = "westus"
}
```

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the Azure Front Door profile. This will also be used as a prefix to all associated resources' names.

**Since:** 0.0.1

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

Additional tags for the Azure Front Door

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#endpoints">Endpoints</a>))</code></td>
    <td width="100%">endpoints</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Defines Front Door endpoints with associating routes

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(object(<a href="#origingroups">OriginGroups</a>))</code></td>
    <td width="100%">origin_groups</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Defines Front Door origin groups with associating origins, in `origin_group_name = {config}` format

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">response_timeout_seconds</td>
    <td><code>120</code></td>
</tr>
<tr><td colspan="3">

Number of seconds before the send/received request times out. Valid values `16 - 240`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">tier</td>
    <td><code>"Standard"</code></td>
</tr>
<tr><td colspan="3">

Define the tier of the Front Door service.

**Allowed Values:**

- `Standard`
- `Premium`

**Since:** 0.0.1

</td></tr>
</tbody></table>

## Outputs

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        </tbody></table>

## Objects

#### Azure

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">resource_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure resource group where the Front Door will be deployed

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">location</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of an Azure location where the Front Door will be deployed. If unspecified, the resource group's location will be used.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Endpoints

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#routes">Routes</a>))</code></td>
    <td width="100%">routes</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a map of routes, in `route_name = {configuration}` format

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables the endpoint

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td></td>
</tr>
<tr><td colspan="3">

Additional tags for the endpoint

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### HealthProbe

Configures the health probe of this origin group

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">protocol</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the protocol to use for health probe.

**Allowed Values:**

- `Http`
- `Https`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">interval_seconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the number of seconds between health probes. Possible values are between `5` and `31536000` seconds

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">probe_method</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the type of health probe request that is made.

**Allowed Values:**

- `GET`
- `HEAD`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">path</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies the path relative to the origin that is used to determine the health of the origin.

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### LoadBalancing

Configure the load balancing settings to define what sample set we need to use to call the backend as healthy or unhealthy

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">latency_sensitivity_milliseconds</td>
    <td></td>
</tr>
<tr><td colspan="3">

Latency sensitivity for identifying backends with least latency. Possible values are between `0` and `1000`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">sample_size</td>
    <td></td>
</tr>
<tr><td colspan="3">

Sample size to assess backend availability. Possible values are between `0` and `255`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">successful_samples_required</td>
    <td></td>
</tr>
<tr><td colspan="3">

Successful samples required to declare the backend healthy. Possible values are between `0` and `255`

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### OriginGroups

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#origins">Origins</a>))</code></td>
    <td width="100%">origins</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines a map of origins, in `origin_name = {configuration}` format

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">session_affinity_enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies whether session affinity should be enabled on this host

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#healthprobe">HealthProbe</a>)</code></td>
    <td width="100%">health_probe</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the health probe of this origin group

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>object(<a href="#loadbalancing">LoadBalancing</a>)</code></td>
    <td width="100%">load_balancing</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configure the load balancing settings to define what sample set we need to use to call the backend as healthy or unhealthy

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Origins

Defines a map of origins, in `origin_name = {configuration}` format

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">hostname</td>
    <td></td>
</tr>
<tr><td colspan="3">

The IPv4 address, IPv6 address or Domain name of the Origin

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">certificate_subject_name_validation</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specifies whether certificate name checks are enabled for this origin

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">http_port</td>
    <td></td>
</tr>
<tr><td colspan="3">

The value of the HTTP port. Must be between `1` and `65535`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">https_port</td>
    <td></td>
</tr>
<tr><td colspan="3">

The value of the HTTPS port. Must be between `1` and `65535`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">origin_host_header</td>
    <td></td>
</tr>
<tr><td colspan="3">

The host header value (an IPv4 address, IPv6 address or Domain name), which is sent to the origin with each request. If unspecified the hostname from the request will be used.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">priority</td>
    <td></td>
</tr>
<tr><td colspan="3">

Priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy. Must be between `1` and `5`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td></td>
</tr>
<tr><td colspan="3">

The weight of the origin in a given origin group for load balancing. Must be between `1` and `1000`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables the origin

**Since:** 0.0.1

</td></tr>
</tbody></table>

#### Routes

Defines a map of routes, in `route_name = {configuration}` format

**Since:** 0.0.1

<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">origin_group_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the Front Door Origin Group where this Front Door Route should be created. YOU MUST DEFINE AN ORIGIN GROUP CREATED BY THE SAME MODULE.

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Enables the route

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">forwarding_protocol</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Protocol that will be use when forwarding traffic to backends.

**Allowed Values:**

- `HttpOnly`
- `HttpsOnly`
- `MatchRequest`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">patterns_to_match</td>
    <td></td>
</tr>
<tr><td colspan="3">

The route patterns of the rule

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">accepted_protocols</td>
    <td></td>
</tr>
<tr><td colspan="3">

One or more Protocols supported by this Front Door Route.

**Allowed Values:**

- `Http`
- `Https`

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">origin_path</td>
    <td></td>
</tr>
<tr><td colspan="3">

A directory path on the Front Door Origin that can be used to retrieve content

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">https_redirect_enabled</td>
    <td></td>
</tr>
<tr><td colspan="3">

Automatically redirect HTTP traffic to HTTPS traffic

**Since:** 0.0.1

</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">link_to_default_domain</td>
    <td></td>
</tr>
<tr><td colspan="3">

Defines if this Front Door Route should be linked to the default endpoint

**Since:** 0.0.1

</td></tr>
</tbody></table>

<!-- TFDOCS_EXTRAS_END -->

## Notes

This module does not support the following and they will be implemented in the next release:

- Custom Domains
- Rule Set
