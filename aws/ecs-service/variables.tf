variable "name" {
  type        = string
  description = "The name of the ECS cluster. Associated resources' names will also be prefixed by this value"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the ECS cluster"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "default_capacity_provider_strategy" {
  type = map(object({
    base   = optional(number, 0)
    weight = number
  }))
  description = "Specify the default capacity provider strategy that is used when creating services in the cluster"
  default     = {}
}

variable "default_service_connect_namespace" {
  type        = string
  description = "Specify the name of an AWS Cloud Map namespace for service to service communication"
  default     = null
}

variable "ec2_capacity_providers" {
  type = map(object({
    desired_instances                 = number
    image_id                          = string
    instance_type                     = string
    security_group_ids                = list(string)
    subnet_ids                        = list(string)
    additional_tags                   = optional(map(string), {})
    instance_iam_role                 = optional(string, null)
    max_desired_instances             = optional(number, null)
    min_desired_instances             = optional(number, null)
    root_ebs_volume_size              = optional(number, 30)
    spot_instance_allocation_strategy = optional(string, null)
    ssh_keypair_name                  = optional(string, null)

    enable_managed_scaling = optional(object({
      enable_managed_scaling_draining = optional(bool, true)
      enable_scale_in_protection      = optional(bool, false)
      target_capacity_percent         = optional(number, 100)
    }), {})
  }))
  description = "Configures multiple EC2 capacity providers"
  default     = {}
}

variable "enable_fargate_capacity_provider" {
  type        = bool
  description = "Enables both Fargate and Fargate Spot capacity providers for the cluster"
  default     = true
}

variable "monitoring" {
  type = object({
    enable_container_insights = optional(bool, false)
  })
  description = "Configures ECS monitoring options"
  default     = null
}
