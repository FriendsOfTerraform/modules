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

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">ami_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the ID of the AMI used to launch the instance

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#ebsvolume">EbsVolume</a>)</code></td>
    <td width="100%">ebs_volume</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the root EBS volume

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">key_pair_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the [Key Pair][ec2-key-pair] to use for the instance

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the EC2 instance. All associated resources will also have their
name prefixed with this value

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#networkinterface">NetworkInterface</a>)</code></td>
    <td width="100%">network_interface</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures the primary network interface

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Optional



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(object(<a href="#additionalebsvolumes">AdditionalEbsVolumes</a>))</code></td>
    <td width="100%">additional_ebs_volumes</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures additional EBS volumes attached to this instance.

    
**Examples:**
- [Additional Storage And Network Interfaces](#additional-storage-and-network-interfaces)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#additionalnetworkinterfaces">AdditionalNetworkInterfaces</a>))</code></td>
    <td width="100%">additional_network_interfaces</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures additional ENIs attached to this instance.

    
**Examples:**
- [Additional Storage And Network Interfaces](#additional-storage-and-network-interfaces)

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the EC2 instance

    

    

    
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
    <td><code>string</code></td>
    <td width="100%">cpu_credit_specification</td>
    <td><code>"standard"</code></td>
</tr>
<tr><td colspan="3">

Credit option for CPU usage. Only applicable to the T family.

    

    
**Links:**
- [Standard Credit Mode](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-standard-mode.html)
- [Unlimited Credit Mode](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_auto_recovery</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Enables [EC2 auto recovery][ec2-auto-recovery]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_detailed_monitoring</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [detailed monitoring][ec2-detailed-monitoring]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_instance_hibernation</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [instance hibernation][instance-hibernation]. Changing this option
after the instance launched will result in replacement.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_instance_stop_protection</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [instance stop protection][instance-stop-protection]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_instance_termination_protection</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [instance termination protection][instance-termination-protection]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">get_windows_password</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Retrieves the encrypted administrator password for a running Windows
instance. The values will be exported to the `password_data` output

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_name</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The name of the IAM role to attach to the instance.

    

    
**Links:**
- [EC2 IAM Roles](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#instancemetadataoptions">InstanceMetadataOptions</a>)</code></td>
    <td width="100%">instance_metadata_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [metadata options][instance-metadata-service] of the instance.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">instance_type</td>
    <td><code>"t2.micro"</code></td>
</tr>
<tr><td colspan="3">

Specify the [instance type][ec2-instance-type] of instance

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#resourcebasednamingoptions">ResourceBasedNamingOptions</a>)</code></td>
    <td width="100%">resource_based_naming_options</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [resource based naming options][resource-based-naming-options]
of the instance.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#userdataconfig">UserDataConfig</a>)</code></td>
    <td width="100%">user_data_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configures the [user data][ec2-user-data] of the instance.

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

### Objects



#### AdditionalEbsVolumes



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">device_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the name of the device this EBS volume is mounted to. Please
refer to the following documentations for valid values.
[Windows][device-name-windows], [Linux][device-name-linux]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">size</td>
    <td></td>
</tr>
<tr><td colspan="3">

The size of the EBS volume, in GiB

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">volume_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the [volume type][volume-type].

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the EBS volume

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">delete_on_termination</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether the volume should be destroyed on instance termination

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">final_snapshot</td>
    <td></td>
</tr>
<tr><td colspan="3">

Whether a final snapshot should be taken when the volume is being
destroyed

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the KMS Key to use to encrypt the volume

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">provisioned_iops</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the amount of provisioned IOPS. Only valid for volume_type of
`"io1"`, `"io2"` or `"gp3"`.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">snapshot_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the snapshot ID this volume is created from

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">throughput</td>
    <td></td>
</tr>
<tr><td colspan="3">

Throughput to provision for a volume in mebibytes per second (MiB/s).
This is only valid for volume_type of `"gp3"`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### AdditionalNetworkInterfaces



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">device_index</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the device index this ENI mounted on

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of security group IDs attached to this ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">subnet_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the subnet ID this ENI is created on

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the description of the ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_elastic_fabric_adapter</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [elastic fabric adapter][elastic-fabric-adapter]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_source_destination_checking</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Controls if traffic is routed to the instance when the destination
address does not match the instance. Used for NAT or VPNs

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#privateipaddresses">PrivateIpAddresses</a>)</code></td>
    <td width="100%">private_ip_addresses</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures custom private IP addresses for the ENI.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#prefixdelegation">PrefixDelegation</a>)</code></td>
    <td width="100%">prefix_delegation</td>
    <td></td>
</tr>
<tr><td colspan="3">

Assigns a private CIDR range, either automatically or manually, to the
ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the
management of applications, including container and networking
applications that require multiple IP addresses on an instance. Network
interfaces with prefixes are supported with [instances built on the
Nitro System][nitro-system-type].

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EbsVolume



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">size</td>
    <td></td>
</tr>
<tr><td colspan="3">

The size of the EBS volume, in GiB

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">volume_type</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the [volume type][volume-type]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the EBS volume

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">delete_on_termination</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether the volume should be destroyed on instance termination

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the KMS Key to use to encrypt the volume

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">provisioned_iops</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the amount of provisioned IOPS. Only valid for volume_type of
`"io1"`, `"io2"` or `"gp3"`.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">throughput</td>
    <td></td>
</tr>
<tr><td colspan="3">

Throughput to provision for a volume in mebibytes per second (MiB/s).
This is only valid for volume_type of `"gp3"`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### InstanceMetadataOptions



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">enable_instance_metadata_service</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Whether the instance metadata service is turned on

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">requires_imdsv2</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Requires the use of IMDSv2 when requesting instance metadata

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">allow_tags_in_instance_metadata</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether instance tags are retrievable from instance metadata

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Ipv4

Configures prefix delegation for IPv4

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">auto_assign_count</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the number of prefixes AWS chooses from your VPC subnet's
IPv4 CIDR block and assigns it to your network interface. Mutually
exclusive to `custom_prefixes`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">custom_prefixes</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the prefixes from your VPC subnet's CIDR block to assign it
to your network interface. Mutually exclusive to `auto_assign_count`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NetworkInterface



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of security group IDs attached to this ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">subnet_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the subnet ID this ENI is created on

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the description of the ENI

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_elastic_fabric_adapter</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Enables [elastic fabric adapter][elastic-fabric-adapter]

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_source_destination_checking</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Controls if traffic is routed to the instance when the destination
address does not match the instance. Used for NAT or VPNs

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#privateipaddresses">PrivateIpAddresses</a>)</code></td>
    <td width="100%">private_ip_addresses</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures custom private IP addresses for the ENI.

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#prefixdelegation">PrefixDelegation</a>)</code></td>
    <td width="100%">prefix_delegation</td>
    <td></td>
</tr>
<tr><td colspan="3">

Assigns a private CIDR range, either automatically or manually, to the
ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the
management of applications, including container and networking
applications that require multiple IP addresses on an instance. Network
interfaces with prefixes are supported with [instances built on the
Nitro System][nitro-system-type].

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PrefixDelegation

Assigns a private CIDR range, either automatically or manually, to the
ENI. By assigning [prefixes][ec2-prefixes], you scale and simplify the
management of applications, including container and networking
applications that require multiple IP addresses on an instance. Network
interfaces with prefixes are supported with [instances built on the
Nitro System][nitro-system-type].

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>object(<a href="#ipv4">Ipv4</a>)</code></td>
    <td width="100%">ipv4</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures prefix delegation for IPv4

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### PrivateIpAddresses

Configures custom private IP addresses for the ENI.

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">ipv4</td>
    <td></td>
</tr>
<tr><td colspan="3">

List of private IPv4 addresses to assign to the ENI, the first address
will be used as the primary IP address

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ResourceBasedNamingOptions



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>bool</code></td>
    <td width="100%">use_resource_based_naming_as_os_hostname</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether the `"EC2 instance ID"` is included in the hostname of the
instance. For example: `i-0123456789abcdef.ec2.internal` If false, the
`"private IPv4 address"` of the instance is included in the hostname
instead. For example: `ip-10-24-34-0.ec2.internal`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">answer_dns_hostname_ipv4_request</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether requests to your resource name resolve to the private IPv4
address (A record) of this EC2 instance

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### UserDataConfig



    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">user_data</td>
    <td></td>
</tr>
<tr><td colspan="3">

User data document in clear text. Mutually exclusive to `user_data_base64`

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">user_data_base64</td>
    <td></td>
</tr>
<tr><td colspan="3">

User data document in base64. Mutually exclusive to `user_data`

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[device-name-linux]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html

[device-name-windows]: https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/device_naming.html?icmpid=docs_ec2_console#available-ec2-device-names

[ec2-auto-recovery]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html

[ec2-detailed-monitoring]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html

[ec2-instance-type]: https://aws.amazon.com/ec2/instance-types/

[ec2-key-pair]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

[ec2-prefixes]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-prefix-eni.html

[ec2-user-data]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

[elastic-fabric-adapter]: https://aws.amazon.com/hpc/efa/

[instance-hibernation]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enabling-hibernation.html

[instance-metadata-service]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html

[instance-stop-protection]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html#Using_StopProtection

[instance-termination-protection]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminate-instances-considerations.html#Using_ChangingDisableAPITermination

[nitro-system-type]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances

[resource-based-naming-options]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-naming.html

[volume-type]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html


<!-- TFDOCS_EXTRAS_END -->

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
