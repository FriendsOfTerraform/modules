variable "azure" {
  type = object({
    /// The name of an Azure resource group where the virtual network will be deployed
    ///
    /// @since 0.0.1
    resource_group_name = string

    /// The name of an Azure location where the virtual network will be deployed. If unspecified, the resource group's location will be used.
    ///
    /// @since 0.0.1
    location = optional(string, null)
  })

  description = <<EOT
    The resource group name and the location where the resources will be deployed to

    ```terraform
    azure = {
      resource_group_name = "sandbox"
      location = "westus"
    }
    ```

    @since 0.0.1
  EOT
}

variable "cidr_blocks" {
  type        = list(string)
  description = <<EOT
    List of CIDR blocks for the virtual network

    @since 0.0.1
  EOT
}

variable "ddos_protection_plan_id" {
  type        = string
  description = <<EOT
    Enables DDOS protection

    @since 0.0.1
  EOT
  default     = null
}

variable "name" {
  type        = string
  description = <<EOT
    The name of the virtual network and all of its associated resources

    @since 0.0.1
  EOT
}

variable "additional_dns_server_addresses" {
  type        = list(string)
  description = <<EOT
    Additional DNS server addresses on top of Azure's default DNS server

    @since 0.0.1
  EOT
  default     = []
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the virtual network

    @since 0.0.1
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources in deployed with this module

    @since 0.0.1
  EOT
  default     = {}
}

variable "nat_gateway" {
  type = object({
    /// Enables the NAT gateway if `true`
    ///
    /// @since 0.0.1
    enabled = bool

    /// The CIDR length of the public IP prefix to be used by the NAT gateway. If this value is unspecified, a public IP address will be used instead.
    ///
    /// @since 0.0.1
    public_ip_prefix_length = optional(string, null)

    /// Additional tags for the NAT gateways
    ///
    /// @since 0.0.1
    additional_tags = optional(map(string), {})
  })

  description = <<EOT
    Enables and configures [NAT gateways][azure-nat-gateway] for the virtual network

    ```terraform
    nat_gateway = {
      enabled = true
      public_ip_prefix_length = "28" # 16 IP addresses
    }
    ```

    @example "Basic Usage" #basic-usage
    @since 0.0.1
  EOT

  default = {
    enabled = false
  }
}

variable "service_endpoints" {
  type        = list(string)
  description = <<EOT
    A list of service endpoints to be enabled in all subnets.

    @link "Service endpoints" https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
    @since 0.0.1
  EOT
  default     = []
}

variable "subnets" {
  type = map(object(
    {
      /// The CIDR for the subnet
      ///
      /// @since 0.0.1
      cidr_block = string

      /// The ID of an Azure network security group to be attached to this subnet
      ///
      /// @since 0.0.1
      network_security_group_id = optional(string, null)

      /// The name of a route table to be attached to this subnet
      ///
      /// @since 0.0.1
      route_table_name = optional(string, null)

      /// A list of service endpoints to be enabled in this subnet
      ///
      /// @since 0.0.1
      service_endpoints = optional(list(string), [])
    }
  ))

  description = <<EOT
    Creates and configures subnets. Expected input in the `{subnetName = {configuration}}` format.

    ```terraform
    subnets = {
      subnet-1 = { cidr_block = "10.0.0.0/26" }  # Creates a subnet named subnet-1 with the cidr 10.0.0.0/26
      subnet-2 = { cidr_block = "10.0.0.64/26" } # Creates a subnet named subnet-2 with the cidr 10.0.0.64/26
    }
    ```

    @example "Basic Usage" #basic-usage
    @since 0.0.1
  EOT
  default     = {}
}
