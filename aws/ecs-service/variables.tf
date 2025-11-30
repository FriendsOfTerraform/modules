variable "name" {
  type        = string
  description = <<EOT
    The name of the ECS cluster. Associated resources will also have their name prefixed with this value

    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the ECS cluster

    @since 1.0.0
  EOT
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = <<EOT
    Additional tags for all resources deployed with this module

    @since 1.0.0
  EOT
  default     = {}
}

variable "default_capacity_provider_strategy" {
  type = map(object({
    /// The relative percentage of the total number of launched tasks that should use the specified capacity provider.
    /// `weight` is taken into consideration only after the `base` count of tasks has been satisfied.
    ///
    /// @since 1.0.0
    weight = number

    /// The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider
    /// in a capacity provider strategy can have `base` defined. Defaults to `0`.
    ///
    /// @since 1.0.0
    base = optional(number, 0)
  }))
  description = <<EOT
    Specify the default capacity provider strategy that is used when creating services in the cluster.

    @example "EC2 Providers" #ec2-providers
    @since 1.0.0
  EOT
  default     = {}
}

variable "default_service_connect_namespace" {
  type        = string
  description = <<EOT
    Specify a default Service Connect namespace that is used when you create a service and don't specify a Service Connect configuration

    @since 1.0.0
  EOT
  default     = null
}

variable "ec2_capacity_providers" {
  type = map(object({
    /// Specify the number of EC2 instances that should be running in the group
    ///
    /// @since 1.0.0
    desired_instances = number

    /// The AMI from which to launch the instance. Please refer to the links below for instruction on how to get the image IDs for ECS optimized images:
    ///
    /// - [linux][ecs-linux-optimized-ami]
    /// - [windows][ecs-windows-optimized-ami]
    /// - [bottlerocket][ecs-bottlerocket-optimized-ami]
    ///
    /// @link {ecs-linux-optimized-ami} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html#ecs-optimized-ami-parameter-examples
    /// @link {ecs-windows-optimized-ami} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_windows_AMI.html#ecs-optimized-ami-windows-parameter-examples
    /// @link {ecs-bottlerocket-optimized-ami} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-bottlerocket-retrieve-ami.html
    /// @since 1.0.0
    image_id = string

    /// Specify the [EC2 instance type][ec2-instance-type]
    ///
    /// @link {ec2-instance-type} https://aws.amazon.com/ec2/instance-types/
    /// @since 1.0.0
    instance_type = string

    /// A list of security group IDs to associate with the instances
    ///
    /// @since 1.0.0
    security_group_ids = list(string)

    /// List of subnet IDs to launch resources in. It is recommended to spread the resources in subnets located in multiple availability zones.
    ///
    /// @since 1.0.0
    subnet_ids = list(string)

    /// Additional tags to be attached to the instances at launch
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// The name of an IAM role to be attached to the instance. If not specified, a default one will be created and attached.
    ///
    /// @link "Create Custom IAM Role" https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
    /// @since 1.0.0
    instance_iam_role = optional(string, null)

    /// Maximum instances to scale to
    ///
    /// @since 1.0.0
    max_desired_instances = optional(number, null)

    /// Minimum instances to scale to
    ///
    /// @since 1.0.0
    min_desired_instances = optional(number, null)

    /// The size of the root volume in GB
    ///
    /// @since 1.0.0
    root_ebs_volume_size = optional(number, 30)

    /// Specify the [spot instance allocation strategy][spot-allocation-strategy].
    ///
    /// @enum lowest-price|capacity-optimized|capacity-optimized-prioritized|price-capacity-optimized
    /// @link {spot-allocation-strategy} https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-allocation-strategy.html
    /// @since 1.0.0
    spot_instance_allocation_strategy = optional(string, null)

    /// The instance key pair to be used to SSH into the instance
    ///
    /// @since 1.0.0
    ssh_keypair_name = optional(string, null)

    /// Enables managed scaling to have Amazon ECS manage the scale-in and scale-out actions of the Auto Scaling group
    ///
    /// @since 1.0.0
    enable_managed_scaling = optional(object({
      /// Enables managed instance draining to have Amazon ECS gracefully drain EC2 instances in an Auto Scaling group
      ///
      /// @since 1.0.0
      enable_managed_scaling_draining = optional(bool, true)

      /// Enables scale-in protection to prevent the Amazon EC2 instances in the Auto Scaling group from being terminated during a scale-in action
      ///
      /// @since 1.0.0
      enable_scale_in_protection = optional(bool, false)

      /// When managed scaling is turned on, the target capacity value is used as the target value for the CloudWatch metric used in the Amazon ECS-managed
      /// target tracking scaling policy. For example, a value of 100 will result in the Amazon EC2 instances in your Auto Scaling group being completely utilized.
      ///
      /// @since 1.0.0
      target_capacity_percent = optional(number, 100)
    }), {})
  }))
  description = <<EOT
    Configures multiple EC2 capacity providers for the cluster.

    @example "EC2 Providers" #ec2-providers
    @since 1.0.0
  EOT
  default     = {}
}

variable "enable_fargate_capacity_provider" {
  type        = bool
  description = <<EOT
    Enables the [FARGATE and the FARGATE_SPOT][ecs-fargate] capacity providers

    @link {ecs-fargate} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
    @since 1.0.0
  EOT
  default     = true
}

variable "monitoring" {
  type = object({
    /// Enables [ECS container insights][ecs-container-insights]
    ///
    /// @link {ecs-container-insights} https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-container-insights.html
    /// @since 1.0.0
    enable_container_insights = optional(bool, false)
  })
  description = <<EOT
    Configures ECS monitoring options

    @since 1.0.0
  EOT
  default     = null
}
