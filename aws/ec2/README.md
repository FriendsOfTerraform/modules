# EC2 Module

This module will build and configure an [EC2](https://aws.amazon.com/ec2/) instance

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [Additional Storage And Network Interfaces](#additional-storage-and-network-interfaces)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)

## Example Usage

### Basic Usage

```terraform
module "demo_ec2" {
  source = "github.com/FriendsOfTerraform/aws-ec2.git?ref=v1.0.0"

  name          = "demo-ec2"
  ami_id        = "ami-06d4b7182ac3480fa" # Amazon Linux 2003
  key_pair_name = "teamA-keypair"

  ebs_volume = {
    size        = 100
    volume_type = "gp3"
  }

  network_interface = {
    security_group_ids = ["sg-0d9f1fb631babcdef0"]
    subnet_id          = "subnet-0645cf5ad5abcdef0"
  }
}
```

### Additional Storage And Network Interfaces

This example demonstrates how to add additonal network interfaces (ENIs) and ebs volumes to the instance. These resources are managed with the instance as a whole and sharing the same lifecycle. If you need to retain those resources beyond the instance's lifecycle, you may create them separately and then attach them to the instance.

```terraform
module "demo_ec2" {
  source = "github.com/FriendsOfTerraform/aws-ec2.git?ref=v1.0.0"

  name          = "demo-ec2"
  ami_id        = "ami-06d4b7182ac3480fa" # Amazon Linux 2003
  key_pair_name = "teamA-keypair"

  ebs_volume = {
    size        = 100
    volume_type = "gp3"
  }

  network_interface = {
    security_group_ids = ["sg-0d9f1fb631babcdef0"]
    subnet_id          = "subnet-0645cf5ad5abcdef0"
  }

  # Manages multiple additional EBS volumes attached to this instance
  additional_ebs_volumes = {
    # The key of the map will be the name of the volume
    data = {
      device_name = "/dev/sdf"
      size        = 50
      volume_type = "gp3"
    }
    backup = {
      device_name = "/dev/sdg"
      size        = 100
      volume_type = "gp3"
    }
  }

  # Manages multiple additional ENIs attached to this instance
  additional_network_interfaces = {
    # The key of the map will be the name of the ENI
    "backup-eni" = {
      device_index       = 1
      security_group_ids = ["sg-083ef10e81abcdef0"]
      subnet_id          = "subnet-0c7b976f59abcdef0"
      description        = "ENI connected to the backup network"
    }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`ami_id`** _[since v1.0.0]_

    Specify the ID of the AMI used to launch the instance

- (object) **`ebs_volume`** _[since v1.0.0]_

    Configures the root EBS volume

    - (number) **`size`** _[since v1.0.0]_

        The size of the EBS volume, in GiB

    - (string) **`volume_type`** _[since v1.0.0]_

        Specify the [volume type][volume-type]. Valid values are `"standard"`, `"gp2"`, `"gp3"`, `"io1"`, `"io2"`, `"sc1"`, `"st1"`

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the EBS volume

    - (bool) **`delete_on_termination = true`** _[since v1.0.0]_

        Whether the volume should be destroyed on instance termination

    - (string) **`kms_key_id = null`** _[since v1.0.0]_

        ARN of the KMS Key to use to encrypt the volume

    - (number) **`provisioned_iops = null`** _[since v1.0.0]_

        Specify the amount of provisioned IOPS. Only valid for volume_type of `"io1"`, `"io2"` or `"gp3"`.

    - (number) **`throughput = null`** _[since v1.0.0]_

        Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of `"gp3"`

- (string) **`key_pair_name`** _[since v1.0.0]_

    Specify the name of the [Key Pair][ec2-key-pair] to use for the instance

- (string) **`name`** _[since v1.0.0]_

    The name of the EC2 instance. All associated resources will also have their name prefixed with this value

- (object) **`network_interface`** _[since v1.0.0]_

    Configures the primary network interface

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        List of security group IDs attached to this ENI

    - (string) **`subnet_id`** _[since v1.0.0]_

        Specify the subnet ID this ENI is created on

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the ENI

    - (string) **`description = null`** _[since v1.0.0]_

        Specify the description of the ENI

    - (bool) **`enable_elastic_fabric_adapter = false`** _[since v1.0.0]_

        Enables [elastic fabric adapter][elastic-fabric-adapter]

    - (bool) **`enable_source_destination_checking = true`** _[since v1.0.0]_

        Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs

    - (object) **`private_ip_addresses = null`** _[since v1.0.0]_

        Configures custom private IP addresses for the ENI.

        - (list(string)) **`ipv4 = null`** _[since v1.0.0]_

            List of private IPv4 addresses to assign to the ENI, the first address will be used as the primary IP address

    - (object) **`prefix_delegation = null`** _[since v1.0.0]_

        Assigns a private CIDR range, either automatically or manually, to the ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the management of applications, including container and networking applications that require multiple IP addresses on an instance. Network interfaces with prefixes are supported with [instances built on the Nitro System][nitro-system-type].

        - (object) **`ipv4 = null`** _[since v1.0.0]_

            Configures prefix delegation for IPV4

            - (number) **`auto_assign_count = null`** _[since v1.0.0]_

                Sepcify the number of prefixes AWS chooses from your VPC subnet’s IPv4 CIDR block and assigns it to your network interface. Mutually exclusive to `custom_prefixes`

            - (list(string)) **`custom_prefixes = null`** _[since v1.0.0]_

                Specify the prefixes from your VPC subnet’s CIDR block to assign it to your network interface. Mutually exclusive to `auto_assign_count`

### Optional

- (map(object)) **`additional_ebs_volumes = {}`** _[since v1.0.0]_

    Configures additional EBS volumes attached to this instance. [See example](#additional-storage-and-network-interfaces)

    - (string) **`device_name`** _[since v1.0.0]_

        Specify the name of the device this EBS volume is mounted to. Please refer to the following documentations for valid values. [Windows][device-name-windows], [Linux][device-name-linux]

    - (number) **`size`** _[since v1.0.0]_

        The size of the EBS volume, in GiB

    - (string) **`volume_type`** _[since v1.0.0]_

        Specify the [volume type][volume-type]. Valid values are `"standard"`, `"gp2"`, `"gp3"`, `"io1"`, `"io2"`, `"sc1"`, `"st1"`

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the EBS volume

    - (bool) **`delete_on_termination = true`** _[since v1.0.0]_

        Whether the volume should be destroyed on instance termination

    - (bool) **`final_snapshot = false`** _[since v1.0.0]_

        Whether a final snapshot should be taken when the volume is being destroyed

    - (string) **`kms_key_id = null`** _[since v1.0.0]_

        ARN of the KMS Key to use to encrypt the volume

    - (number) **`provisioned_iops = null`** _[since v1.0.0]_

        Specify the amount of provisioned IOPS. Only valid for volume_type of `"io1"`, `"io2"` or `"gp3"`.

    - (string) **`snapshot_id = null`** _[since v1.0.0]_

        Specify the snapshot ID this volume is created from

    - (number) **`throughput = null`** _[since v1.0.0]_

        Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of `"gp3"`

- (map(object)) **`additional_network_interfaces = {}`** _[since v1.0.0]_

    Configures additional ENIs attached to this instance. [See example](#additional-storage-and-network-interfaces)

    - (number) **`device_index`** _[since v1.0.0]_

        Specify the device index this ENI mounted on

    - (list(string)) **`security_group_ids`** _[since v1.0.0]_

        List of security group IDs attached to this ENI

    - (string) **`subnet_id`** _[since v1.0.0]_

        Specify the subnet ID this ENI is created on

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the ENI

    - (string) **`description = null`** _[since v1.0.0]_

        Specify the description of the ENI

    - (bool) **`enable_elastic_fabric_adapter = false`** _[since v1.0.0]_

        Enables [elastic fabric adapter][elastic-fabric-adapter]

    - (bool) **`enable_source_destination_checking = true`** _[since v1.0.0]_

        Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs

    - (object) **`private_ip_addresses = null`** _[since v1.0.0]_

        Configures custom private IP addresses for the ENI.

        - (list(string)) **`ipv4 = null`** _[since v1.0.0]_

            List of private IPv4 addresses to assign to the ENI, the first address will be used as the primary IP address

    - (object) **`prefix_delegation = null`** _[since v1.0.0]_

        Assigns a private CIDR range, either automatically or manually, to the ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the management of applications, including container and networking applications that require multiple IP addresses on an instance. Network interfaces with prefixes are supported with [instances built on the Nitro System][nitro-system-type].

        - (object) **`ipv4 = null`** _[since v1.0.0]_

            Configures prefix delegation for IPV4

            - (number) **`auto_assign_count = null`** _[since v1.0.0]_

                Sepcify the number of prefixes AWS chooses from your VPC subnet’s IPv4 CIDR block and assigns it to your network interface. Mutually exclusive to `custom_prefixes`

            - (list(string)) **`custom_prefixes = null`** _[since v1.0.0]_

                Specify the prefixes from your VPC subnet’s CIDR block to assign it to your network interface. Mutually exclusive to `auto_assign_count`

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the EC2 instance

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (string) **`cpu_credit_specification = "standard"`** _[since v1.0.0]_

    Credit option for CPU usage. Valid values are `"standard"`, `"unlimited"`. Only applicable to the T family. Please refer to these documentations for more information on [standard][cpu-credit-standard] and [unlimited][cpu-credit-unlimited] mode.

- (bool) **`enable_auto_recovery = true`** _[since v1.0.0]_

    Enables [EC2 auto recovery][ec2-auto-recovery]

- (bool) **`enable_detailed_monitoring = false`** _[since v1.0.0]_

    Enables [detailed monitoring][ec2-detailed-monitoring]

- (bool) **`enable_instance_hibernation = false`** _[since v1.0.0]_

    Enables [instance hibernation][instance-hibernation]. Changing this option after the instance launched will result in replacement.

- (bool) **`enable_instance_termination_protection = false`** _[since v1.0.0]_

    Enables [instance termination protection][instance-termination-protection]

- (bool) **`enable_instance_stop_protection = false`** _[since v1.0.0]_

    Enables [instance stop protection][instance-stop-protection]

- (bool) **`get_windows_password = false`** _[since v1.0.0]_

    Retrieves the encrypted administrator password for a running Windows instance. The values will be exported to the `password_data` output

- (string) **`iam_role_name = null`** _[since v1.0.0]_

    The name of the IAM role to attach to the instance. Please refer to [this documentation][ec2-iam-role] for more information.

- (object) **`instance_metadata_options = null`** _[since v1.0.0]_

    Configures the [metadata options][instance-metadata-service] of the instance.

    - (bool) **`enable_instance_metadata_service = true`** _[since v1.0.0]_

        Whether the instance metadata service is turned on

    - (bool) **`requires_imdsv2 = true`** _[since v1.0.0]_

        Requires the use of IMDSv2 when requesting instance metadata

    - (bool) **`allow_tags_in_instance_metadata = false`** _[since v1.0.0]_

        Whether instance tags are retrivable from instance metadata

- (string) **`instance_type = "t2.micro"`** _[since v1.0.0]_

    Specify the [instance type][ec2-instance-type] of instance

- (object) **`resource_based_naming_options = null`** _[since v1.0.0]_

    Configures the [resource based naming options][resource-based-naming-options] of the instance.

    - (bool) **`use_resource_based_naming_as_os_hostname = false`** _[since v1.0.0]_

        Whether the `"EC2 instance ID"` is included in the hostname of the instance. For example: `i-0123456789abcdef.ec2.internal` If false, the `"private IPv4 address"` of the instance is included in the hostname instead. For example: `ip-10-24-34-0.ec2.internal`

    - (bool) **`answer_dns_hostname_ipv4_request = false`** _[since v1.0.0]_

        whether requests to your resource name resolve to the private IPv4 address (A record) of this EC2 instance

- (object) **`user_data_config = null`** _[since v1.0.0]_

    Configures the [user data][ec2-user-data] of the instance.

    - (string) **`user_data = null`** _[since v1.0.0]_

        User data document in clear text. Mutually exclusive to `user_data_base64`

    - (string) **`user_data_base64 = null`** _[since v1.0.0]_

        User data document in base64. Mutually exclusive to `user_data`

## Outputs

- (string) **`instance_arn`** _[since v1.0.0]_

    The ARN of the EC2 instance

- (string) **`instance_password_data`** _[since v1.0.0]_

    Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_windows_password = true`

- (string) **`instance_primary_network_interface_id`** _[since v1.0.0]_

    ID of the instance's primary network interface

- (string) **`instance_private_dns`** _[since v1.1.0]_

    Private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC

- (string) **`instance_public_dns`** _[since v1.1.0]_

    Public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC.

[cpu-credit-standard]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-standard-mode.html
[cpu-credit-unlimited]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html
[device-name-linux]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
[device-name-windows]:https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/device_naming.html?icmpid=docs_ec2_console#available-ec2-device-names
[ec2-auto-recovery]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
[ec2-detailed-monitoring]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html
[ec2-iam-role]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
[ec2-instance-type]:https://aws.amazon.com/ec2/instance-types/
[ec2-key-pair]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
[ec2-prefixes]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-prefix-eni.html
[ec2-user-data]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
[elastic-fabric-adapter]:https://aws.amazon.com/hpc/efa/
[instance-hibernation]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enabling-hibernation.html
[instance-metadata-service]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html
[instance-termination-protection]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminate-instances-considerations.html#Using_ChangingDisableAPITermination
[instance-stop-protection]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection
[nitro-system-type]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances
[resource-based-naming-options]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-naming.html
[volume-type]:https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
