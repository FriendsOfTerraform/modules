# SES Module

This module configures Amazon [Simple Email Service (SES)](https://aws.amazon.com/ses/) with email identities, configuration sets, dedicated IP pools, and related resources.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Email Identities with DKIM](#email-identities-with-dkim)
    - [Configuration Sets](#configuration-sets)
    - [Dedicated IP Pools](#dedicated-ip-pools)
    - [Custom Mail From Domain](#custom-mail-from-domain)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

This example creates a simple email identity and configuration set

```terraform
module "ses_basic" {
  source = "github.com/FriendsOfTerraform/aws-ses.git?ref=v1.0.0"

  domains = {
    # Manages multiple domain
    # Keys of the map are the domain names
    "example.com" = {
      email_addresses = {
        # Manages multiple email addresses
        # Keys of the map are the email addresses
        # Email addresses can either include or omit the domain name
        peter = {}
        "stewie@example.com" = {}
      }
    }
  }
}
```

### Email Identities with DKIM

This example creates email identities with DKIM configuration and email addresses

```terraform
module "ses_with_dkim" {
  source = "github.com/FriendsOfTerraform/aws-ses.git?ref=v1.0.0"

  domains = {
    "example.com" = {
      additional_tags = {
        Environment = "production"
      }

      default_configuration_set = "default"

      dkim_settings = {
        dkim_signatures_enabled = true

        easy_dkim = {
          signing_key_length = "RSA_2048_BIT"
        }
      }

      email_addresses = {
        "noreply@example.com" = {
          additional_tags = {
            Type = "noreply"
          }
        }
        "support@example.com" = {
          additional_tags = {
            Type = "support"
          }
        }
      }
    }
  }

  configuration_sets = {
    "default" = {
      additional_tags = {
        Environment = "production"
      }

      reputation_metrics_enabled = true
    }
  }
}
```

### Configuration Sets

This example demonstrates configuration sets with delivery options and suppression settings

```terraform
module "ses_configuration_sets" {
  source = "github.com/FriendsOfTerraform/aws-ses.git?ref=v1.0.0"

  domains = {
    "example.com" = {}
  }

  configuration_sets = {
    "default" = {
      additional_tags = {
        Environment = "production"
      }

      require_tls                = true
      reputation_metrics_enabled = true
      maximum_delivery_duration  = "300 seconds"

      override_account_level_settings = {
        suppression_list_settings = {
          suppression_reason = ["BOUNCE", "COMPLAINT"]
        }

        virtual_deliverability_manager_options = {
          engagement_tracking_enabled       = true
          optimized_shared_delivery_enabled = true
        }
      }

      use_a_custom_redirect_domain = {
        domain_name  = "tracking.example.com"
        https_policy = "REQUIRE"
      }
    }
  }
}
```

### Dedicated IP Pools

This example demonstrates creating dedicated IP pools for better email deliverability

```terraform
module "ses_dedicated_ips" {
  source = "github.com/FriendsOfTerraform/aws-ses.git?ref=v1.0.0"

  domains = {
    "example.com" = {
      default_configuration_set = "dedicated"
    }
  }

  configuration_sets = {
    "dedicated" = {
      sending_ip_pool = "production-pool"
      require_tls     = true
    }
  }

  dedicated_ip_pools = {
    "production-pool" = {
      additional_tags = {
        Environment = "production"
      }

      ip_addresses = [
        "192.0.2.1",
        "192.0.2.2"
      ]

      scaling_mode = "MANAGED"
    }
  }
}
```

### Custom Mail From Domain

This example demonstrates setting up a custom MAIL FROM domain

```terraform
module "ses_custom_mail_from" {
  source = "github.com/FriendsOfTerraform/aws-ses.git?ref=v1.0.0"

  domains = {
    "example.com" = {
      additional_tags = {
        Environment = "production"
      }

      use_custom_mail_from_domain = {
        subdomain_name         = "bounce"
        behavior_on_mx_failure = "USE_DEFAULT_VALUE"
      }
    }
  }

  configuration_sets = {
    "default" = {
      additional_tags = {
        Environment = "production"
      }
    }
  }
}
```

## Argument Reference

### Mandatory

None. All arguments are optional, but you typically need to define at least one `domains` entry.

### Optional

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`domains = {}`** _[since v1.0.0]_

    Manages SES email domains and identities. Please [see example](#email-identities-with-dkim).

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the domain identity

    - (string) **`default_configuration_set = null`** _[since v1.0.0]_

        The default configuration set to use for this domain. Must reference a key from `configuration_sets`

    - (object) **`dkim_settings = null`** _[since v1.0.0]_

        Configures DKIM signing for the domain. Please [see example](#email-identities-with-dkim)

        - (bool) **`dkim_signatures_enabled = true`** _[since v1.0.0]_

            Whether to enable DKIM signatures

        - (object) **`easy_dkim = null`** _[since v1.0.0]_

            Configures easy DKIM. Mutually exclusive with `provide_dkim_authentication_token`

            - (string) **`signing_key_length = "RSA_2048_BIT"`** _[since v1.0.0]_

                The DKIM signing key length. Valid values: `"RSA_1024_BIT"`, `"RSA_2048_BIT"`

        - (object) **`provide_dkim_authentication_token = null`** _[since v1.0.0]_

            Provides your own DKIM authentication tokens. Mutually exclusive with `easy_dkim`

            - (string) **`private_key`** _[since v1.0.0]_

                The DKIM signing private key

            - (string) **`selector_name`** _[since v1.0.0]_

                The DKIM selector name

    - (map(object)) **`email_addresses = {}`** _[since v1.0.0]_

        Manages email address identities for the domain. Please [see example](#email-identities-with-dkim)

        - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

            Additional tags for the email address identity

        - (string) **`default_configuration_set = null`** _[since v1.0.0]_

            The default configuration set to use for this email address. Must reference a key from `configuration_sets`

    - (object) **`use_custom_mail_from_domain = null`** _[since v1.0.0]_

        Configures a custom MAIL FROM domain. Please [see example](#custom-mail-from-domain)

        - (string) **`subdomain_name = null`** _[since v1.0.0]_

            The subdomain to use as the MAIL FROM domain (e.g., "bounce" for bounce.example.com)

        - (string) **`behavior_on_mx_failure = "USE_DEFAULT_VALUE"`** _[since v1.0.0]_

            Behavior when MX record lookup fails. Valid values: `"USE_DEFAULT_VALUE"`, `"REJECT_MESSAGE"`

- (map(object)) **`configuration_sets = {}`** _[since v1.0.0]_

    Manages SES configuration sets. Please [see example](#configuration-sets).

    - (string) **`sending_ip_pool = null`** _[since v1.0.0]_

        The name of the dedicated IP pool to associate with this configuration set. Must reference a key from `dedicated_ip_pools`

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the configuration set

    - (bool) **`require_tls = false`** _[since v1.0.0]_

        Require TLS for all outgoing emails

    - (string) **`maximum_delivery_duration = null`** _[since v1.0.0]_

        The maximum delivery duration for emails. Format: `"<number> <unit>s"`. Example: `"300 seconds"`

    - (bool) **`reputation_metrics_enabled = false`** _[since v1.0.0]_

        Enable reputation metrics for the configuration set

    - (object) **`override_account_level_settings = null`** _[since v1.0.0]_

        Override account-level settings for this configuration set. Please [see example](#configuration-sets)

        - (object) **`suppression_list_settings = null`** _[since v1.0.0]_

            Configure suppression list settings

            - (list(string)) **`suppression_reason = ["BOUNCE", "COMPLAINT"]`** _[since v1.0.0]_

                The suppression reasons. Valid values: `"BOUNCE"`, `"COMPLAINT"`

        - (object) **`virtual_deliverability_manager_options = null`** _[since v1.0.0]_

            Configure Virtual Deliverability Manager options

            - (bool) **`engagement_tracking_enabled = false`** _[since v1.0.0]_

                Enable engagement tracking

            - (bool) **`optimized_shared_delivery_enabled = false`** _[since v1.0.0]_

                Enable optimized shared delivery

    - (object) **`use_a_custom_redirect_domain = null`** _[since v1.0.0]_

        Configure a custom redirect domain for tracking links. Please [see example](#configuration-sets)

        - (string) **`domain_name`** _[since v1.0.0]_

            The domain name to use for tracking redirects

        - (string) **`https_policy = "OPTIONAL"`** _[since v1.0.0]_

            HTTPS policy for the redirect domain. Valid values: `"OPTIONAL"`, `"REQUIRE"`

- (map(object)) **`dedicated_ip_pools = {}`** _[since v1.0.0]_

    Manages dedicated IP pools. Please [see example](#dedicated-ip-pools).

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the dedicated IP pool

    - (list(string)) **`ip_addresses = []`** _[since v1.0.0]_

        List of dedicated IP addresses to add to the pool

    - (string) **`scaling_mode = "MANAGED"`** _[since v1.0.0]_

        The scaling mode for the pool. Valid values: `"MANAGED"`, `"STANDARD"`

- (map(object)) **`tenants = {}`** _[since v1.0.0]_

    Manages SES tenants (multi-tenant support)

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the tenant

## Outputs

Currently, the module does not export any outputs. You can access resource attributes directly through the resource references (e.g., `aws_sesv2_email_identity`, `aws_sesv2_configuration_set`, etc.).
