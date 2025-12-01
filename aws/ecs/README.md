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

The name of the ECS cluster. Associated resources will also have their name prefixed with this value

    

    

    
**Since:** 1.0.0
        


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

Additional tags for the ECS cluster

    

    

    
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
    <td><code>map(object(<a href="#defaultcapacityproviderstrategy">DefaultCapacityProviderStrategy</a>))</code></td>
    <td width="100%">default_capacity_provider_strategy</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Specify the default capacity provider strategy that is used when creating services in the cluster.

    
**Examples:**
- [EC2 Providers](#ec2-providers)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">default_service_connect_namespace</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify a default Service Connect namespace that is used when you create a
service and don't specify a Service Connect configuration

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#ec2capacityproviders">Ec2CapacityProviders</a>))</code></td>
    <td width="100%">ec2_capacity_providers</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures multiple EC2 capacity providers for the cluster.

    
**Examples:**
- [EC2 Providers](#ec2-providers)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_fargate_capacity_provider</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enables the [FARGATE and the FARGATE_SPOT][ecs-fargate] capacity providers

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#monitoring">Monitoring</a>)</code></td>
    <td width="100%">monitoring</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures ECS monitoring options

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Objects



#### DefaultCapacityProviderStrategy



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td></td>
</tr>
<tr><td colspan="3">

The relative percentage of the total number of launched tasks that should use the specified capacity provider.
`weight` is taken into consideration only after the `base` count of tasks has been satisfied.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">base</td>
    <td><code>0</code></td>
</tr>
<tr><td colspan="3">

The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider
in a capacity provider strategy can have `base` defined. Defaults to `0`.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Ec2CapacityProviders



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">desired_instances</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the number of EC2 instances that should be running in the group

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">image_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

The AMI from which to launch the instance. Please refer to the links below for instruction on how to get the image IDs for ECS optimized images:

- [linux][ecs-linux-optimized-ami]
- [windows][ecs-windows-optimized-ami]
- [bottlerocket][ecs-bottlerocket-optimized-ami]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">instance_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the [EC2 instance type][ec2-instance-type]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of security group IDs to associate with the instances

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of subnet IDs to launch resources in. It is recommended to spread the resources in subnets located in multiple availability zones.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags to be attached to the instances at launch

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">instance_iam_role</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of an IAM role to be attached to the instance. If not specified, a default one will be created and attached.

    

    
**Links:**
- [ECS Container Instance IAM Roles](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">max_desired_instances</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Maximum instances to scale to

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">min_desired_instances</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Minimum instances to scale to

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">root_ebs_volume_size</td>
    <td><code>30</code></td>
</tr>
<tr><td colspan="3">

The size of the root volume in GB

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">spot_instance_allocation_strategy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the [spot instance allocation strategy][spot-allocation-strategy]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">ssh_keypair_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The instance key pair to be used to SSH into the instance

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#enablemanagedscaling">EnableManagedScaling</a>)</code></td>
    <td width="100%">enable_managed_scaling</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Enables managed scaling to have Amazon ECS manage the scale-in and scale-out actions of the Auto Scaling group

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EnableManagedScaling

Enables managed scaling to have Amazon ECS manage the scale-in and scale-out actions of the Auto Scaling group

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_managed_scaling_draining</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enables managed instance draining to have Amazon ECS gracefully drain EC2 instances in an Auto Scaling group

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_scale_in_protection</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables scale-in protection to prevent the Amazon EC2 instances in the Auto Scaling group from being terminated during a scale-in action

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">target_capacity_percent</td>
    <td><code>100</code></td>
</tr>
<tr><td colspan="3">

When managed scaling is turned on, the target capacity value is used as the target value for the CloudWatch metric used in the Amazon ECS-managed
target tracking scaling policy. For example, a value of 100 will result in the Amazon EC2 instances in your Auto Scaling group being completely utilized.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Monitoring



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_container_insights</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [ECS container insights][ecs-container-insights]

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[ec2-instance-type]: https://aws.amazon.com/ec2/instance-types/

[ecs-bottlerocket-optimized-ami]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-bottlerocket-retrieve-ami.html

[ecs-container-insights]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-container-insights.html

[ecs-fargate]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html

[ecs-linux-optimized-ami]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html#ecs-optimized-ami-parameter-examples

[ecs-windows-optimized-ami]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_windows_AMI.html#ecs-optimized-ami-windows-parameter-examples

[spot-allocation-strategy]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-allocation-strategy.html


<!-- TFDOCS_EXTRAS_END -->

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
