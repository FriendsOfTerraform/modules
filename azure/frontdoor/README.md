# Azure Front Door Module

This module will create and configure an Azure Front Door and allow you to manage its resources such as origins, endpoints, and routes

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
- [Notes](#notes)

## Example Usage

### Basic Usage

This example creates an Azure Front Door profile with an origin group named `demo-webapp` with two origins. Then creates an endpoint named `default` and route named `webapp` to route traffic to origins behind `demo-webapp`

```terraform
module "Front Door" {
  source = "github.com/FriendsOfTerraform/azure-Front Door.git?ref=v0.0.1"

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

## Argument Reference

### Mandatory

- (object) **`azure`** _[since v0.0.1]_

    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    - (string) **`resource_group_name`** _[since v0.0.1]_

        The name of an Azure resource group where the Front Door will be deployed

    - (string) **`location = null`** _[since v0.0.1]_

        The name of an Azure location where the Front Door will be deployed. If unspecified, the resource group's location will be used.

- (string) **`name`** _[since v0.0.1]_

    The name of the Azure Front Door profile. This will also be used as a prefix to all associated resources' names.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v0.0.1]_

    Additional tags for the Azure Front Door

- (map(string)) **`additional_tags_all = {}`** _[since v0.0.1]_

    Additional tags for all resources deployed with this module

- (map(object)) **`endpoints = {}`** _[since v0.0.1]_

    Defines Front Door endpoints with associating routes

    - (map(string)) **`additional_tags = null`** _[since v0.0.1]_

        Additional tags for the endpoint

    - (bool) **`enabled = true`** _[since v0.0.1]_

        Enables the endpoint

    - (map(object)) **`routes = null`** _[since v0.0.1]_

        Defines a map of routes, in `route_name = {configuration}` format

      - (string) **`origin_group_name`** _[since v0.0.1]_

          The name of the Front Door Origin Group where this Front Door Route should be created. YOU MUST DEFINE AN ORIGIN GROUP CREATED BY THE SAME MODULE.

      - (list(string)) **`accepted_protocols = ["Http", "Https"]`** _[since v0.0.1]_

          One or more Protocols supported by this Front Door Route. Possible values are `Http` or `Https`

      - (bool) **`enabled = true`** _[since v0.0.1]_

          Enables the route

      - (string) **`forwarding_protocol = "MatchRequest"`** _[since v0.0.1]_

          The Protocol that will be use when forwarding traffic to backends. Possible values are `HttpOnly`, `HttpsOnly` or `MatchRequest`

      - (bool) **`https_redirect_enabled = true`** _[since v0.0.1]_

          Automatically redirect HTTP traffic to HTTPS traffic

      - (bool) **`link_to_default_domain = true`** _[since v0.0.1]_

          Defines if this Front Door Route should be linked to the default endpoint

      - (string) **`origin_path = null`** _[since v0.0.1]_

          A directory path on the Front Door Origin that can be used to retrieve content

      - (list(string)) **`patterns_to_match = ["/*"]`** _[since v0.0.1]_

          The route patterns of the rule

- (map(object)) **`origin_groups = {}`** _[since v0.0.1]_

    Defines Front Door origin groups with associating origins, in `origin_group_name = {config}` format

    - (object) **`health_probe = null`** _[since v0.0.1]_

        Configures the health probe of this origin group

      - (number) **`interval_seconds = 100`** _[since v0.0.1]_

          Specifies the number of seconds between health probes. Possible values are between `5` and `31536000` seconds

      - (string) **`path = "/"`** _[since v0.0.1]_

          Specifies the path relative to the origin that is used to determine the health of the origin.

      - (string) **`probe_method = "HEAD"`** _[since v0.0.1]_

          Specifies the type of health probe request that is made. Possible values are `GET` and `HEAD`

      - (string) **`protocol = "Http"`** _[since v0.0.1]_

          Specifies the protocol to use for health probe. Possible values are `Http` and `Https`

    - (object) **`load_balancing = null`** _[since v0.0.1]_

        Configure the load balancing settings to define what sample set we need to use to call the backend as healthy or unhealthy

      - (number) **`latency_sensitivity_milliseconds = 50`** _[since v0.0.1]_

          Latency sensitivity for identifying backends with least latency. Possible values are between `0` and `1000`

      - (number) **`sample_size = 4`** _[since v0.0.1]_

          Sample size to assess backend availability. Possible values are between `0` and `255`

      - (number) **`successful_samples_required = 3`** _[since v0.0.1]_

          Successful samples required to declare the backend healthy. Possible values are between `0` and `255`

    - (map(object)) **`origins = null`** _[since v0.0.1]_

        Defines a map of origins, in `origin_name = {configuration}` format

      - (string) **`hostname`** _[since v0.0.1]_

          The IPv4 address, IPv6 address or Domain name of the Origin

      - (bool) **`certificate_subject_name_validation = true`** _[since v0.0.1]_

          Specifies whether certificate name checks are enabled for this origin

      - (bool) **`enabled = true`** _[since v0.0.1]_

          Enables the origin

      - (number) **`http_port = 80`** _[since v0.0.1]_

          The value of the HTTP port. Must be between `1` and `65535`

      - (number) **`https_port = 443`** _[since v0.0.1]_

          The value of the HTTPS port. Must be between `1` and `65535`

      - (string) **`origin_host_header = null`** _[since v0.0.1]_

          The host header value (an IPv4 address, IPv6 address or Domain name), which is sent to the origin with each request. If unspecified the hostname from the request will be used.

      - (number) **`priority = 1`** _[since v0.0.1]_

          Priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy. Must be between `1` and `5`

      - (number) **`weight = 500`** _[since v0.0.1]_

          The weight of the origin in a given origin group for load balancing. Must be between `1` and `1000`

    - (bool) **`session_affinity_enabled = true`** _[since v0.0.1]_

        Specifies whether session affinity should be enabled on this host

- (number) **`response_timeout_seconds = 120`** _[since v0.0.1]_

    Number of seconds before the send/received request times out. Valid values `16 - 240`

- (string) **`tier = "Standard"`** _[since v0.0.1]_

    Define the tier of the Front Door service. Valid values are `"Standard"` or `"Premium"`

## Notes

This module does not support the following and they will be implemented in the next release:

- Custom Domains
- Rule Set