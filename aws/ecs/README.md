# Elastic Container Service Module

This module will build and configure an [ECS](https://aws.amazon.com/ecs/) cluster with additional capacity providers.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [EC2 Providers](#ec2-providers)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
    - [Editing EC2 Capacity Providers](#editing-ec2-capacity-providers)

## Example Usage

### Basic Usage

This example creates an ECS cluster with the fargate capacity providers

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-ecs.git?ref=v1.0.0"

  name = "demo-ecs-cluster"
}
```

### EC2 Providers

This example demonstrates how to create and manage multiple EC2 capacity providers, then set up default capacity provider strategy.

```terraform
module "ec2_providers" {
  source = "github.com/FriendsOfTerraform/aws-ecs.git?ref=v1.0.0"

  name = "demo-ecs-cluster"

  # Manages multiple ec2 capacity providers
  # The keys of the map will be the capacity provider's name
  ec2_capacity_providers = {
    "linux" = {
      desired_instances  = 1
      image_id           = "ami-053b5d2b2f669d15a" # Amazon Linux 2 Kernel 5.10
      instance_type      = "t3.small"
      security_group_ids = ["sg-35a55e50"]

      subnet_ids = [
        "subnet-0ad12345", # private-us-west-1a
        "subnet-b2312345"  # private-us-west-1b
      ]
    }

    "linux-spot" = {
      desired_instances                 = 1
      image_id                          = "ami-053b5d2b2f669d15a" # Amazon Linux 2
      instance_type                     = "t3.large"
      security_group_ids                = ["sg-35a55e50"]
      instance_iam_role                 = "custom-ecs-role"
      min_desired_instances             = 1
      max_desired_instances             = 5
      spot_instance_allocation_strategy = "lowest-price"

      subnet_ids = [
        "subnet-0ad32d6f", # private-us-west-1a
        "subnet-b23608f4"  # private-us-west-1b
      ]
    }

    "windows" = {
      desired_instances    = 1
      image_id             = "ami-0016ac38fe0fcb3f5" # Windows Server 2022 Core
      instance_type        = "m5.large"
      security_group_ids   = ["sg-35a55e50"]
      root_ebs_volume_size = 100

      subnet_ids = [
        "subnet-0ad32d6f", # private-us-west-1a
        "subnet-b23608f4"  # private-us-west-1b
      ]
    }
  }

  # Default to schedule a minimum of 2 tasks on the linux capacity provider
  # And schedule 80% of to the linux-spot capacity provider
  # The keys of the map must be a capacity provider managed in this module
  default_capacity_provider_strategy = {
    "linux" = {
      weight = 20
    }
    "linux-spot" = {
      base   = 2
      weight = 80
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the ECS cluster. Associated resources will also have their name prefixed with this value

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the ECS cluster

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`default_capacity_provider_strategy = {}`** _[since v1.0.0]_

    Specify the default capacity provider strategy that is used when creating services in the cluster. Please [see example](#ec2-providers)

    - (number) **`weight`** _[since v1.0.0]_

        The relative percentage of the total number of launched tasks that should use the specified capacity provider. `weight` is taken into consideration only after the `base` count of tasks has been satisfied.

    - (number) **`base = 0`** _[since v1.0.0]_

        The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have `base` defined. Defaults to `0`.

- (string) **`default_service_connect_namespace = null`** _[since v1.0.0]_

    Specify a default Service Connect namespace that is used when you create a service and don't specify a Service Connect configuration

- (map(object)) **`ec2_capacity_providers = {}`** _[since v1.0.0]_

    Configures multiple EC2 capacity providers for the cluster. Please [see example](#ec2-providers)

    - (number) **`desired_instances`** _[since v1.0.0]_

        Specify the number of EC2 instances that should be running in the group

    - (string) **`image_id`** _[since v1.0.0]_

        The AMI from which to launch the instance. Please refer to the links below for instruction on how to get the image IDs for ECS optimized images:

        - [linux][ecs-linux-optimized-ami]
        - [windows][ecs-windows-optimized-ami]
        - [bottlerocket][ecs-bottlerocket-optimized-ami]

    - (string) **`instance_type`** _[since v1.0.0]_

        Specify the [EC2 instance type][ec2-instance-type]

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        A list of security group IDs to associate with the instances

    - (list(string)) **`subnet_ids`** _[since v1.0.0]_

        List of subnet IDs to launch resources in. It is recommended to spread the resources in subnets located in multiple availability zones.

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Addtional tags to be attached to the instances at launch

    - (string) **`instance_iam_role = null`** _[since v1.0.0]_

        The name of an IAM role to be attached to the instance, if not specified, a default one will be created and attached. Please refer to [this documentation][ecs-container-instance-iam-role] for information in case of creating a custom role.

    - (number) **`max_desired_instances = null`** _[since v1.0.0]_

        Maximum instances to scale to

    - (number) **`min_desired_instances = null`** _[since v1.0.0]_

        Minimum instances to scale to

    - (number) **`root_ebs_volume_size = 30`** _[since v1.0.0]_

        The size of the root volume in GB

    - (string) **`spot_instance_allocation_strategy = null`** _[since v1.0.0]_

        Specify the [spot instance allocation strategy][spot-allocation-strategy], valid values are: `"lowest-price"`, `"capacity-optimized"`, `"capacity-optimized-prioritized"`, `"price-capacity-optimized"`

    - (string) **`ssh_keypair_name = null`** _[since v1.0.0]_

        The instance key pair to be used to SSH into the instance

    - (object) **`enable_managed_scaling = {}`** _[since v1.0.0]_

        Enables managed scaling to have Amazon ECS manage the scale-in and scale-out actions of the Auto Scaling group

        - (bool) **`enable_managed_scaling_draining = true`** _[since v1.0.0]_

            Enables managed instance draining to have Amazon ECS gracefully drain EC2 instances in an Auto Scaling group.

        - (bool) **`enable_scale_in_protection = false`** _[since v1.0.0]_

            Enables scale-in protection to prevent the Amazon EC2 instances in the Auto Scaling group from being terminated during a scale-in action

        - (number) **`target_capacity_percent = 100`** _[since v1.0.0]_

            When managed scaling is turned on, the target capacity value is used as the target value for the CloudWatch metric used in the Amazon ECS-managed target tracking scaling policy. For example, a value of 100 will result in the Amazon EC2 instances in your Auto Scaling group being completely utilized.

- (bool) **`enable_fargate_capacity_provider = true`** _[since v1.0.0]_

    Enables the [FARGATE and the FARGATE_SPOT][ecs-fargate] capacity providers

- (object) **`monitoring = null`** _[since v1.0.0]_

    Configures ECS monitoring options

    - (bool) **`enable_container_insights = false`** _[since v1.0.0]_

        Enables [ECS container insights][ecs-container-insights]

## Outputs

- (map(string)) **`ec2_capacity_provider_arns`** _[since v1.0.0]_

    Map of ARNs of all EC2 capacity providers

- (string) **`ecs_cluster_arn`** _[since v1.0.0]_

    The ARN of the ECS cluster

## Known Limitations

### Editing EC2 Capacity Providers

Modifications of EC2 capacity providers does not apply to running instances. It is because it only updates the launch template used to launch the fleet. You must replace the running instances to see the changes.

[ec2-instance-type]:https://aws.amazon.com/ec2/instance-types/
[ecs-container-insights]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-container-insights.html
[ecs-container-instance-iam-role]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
[ecs-fargate]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
[ecs-linux-optimized-ami]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html#ecs-optimized-ami-parameter-examples
[ecs-windows-optimized-ami]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_windows_AMI.html#ecs-optimized-ami-windows-parameter-examples
[ecs-bottlerocket-optimized-ami]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-bottlerocket-retrieve-ami.html
[spot-allocation-strategy]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-allocation-strategy.html
