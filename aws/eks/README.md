# Elastic Kubernetes Service Module

This module will build and configure an [EKS](https://aws.amazon.com/eks/) cluster with additional node pools

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
    - [Basic Usage](#basic-usage)
    - [IAM Roles For Service Accounts](#iam-roles-for-service-accounts)
    - [OIDC Identity Provider](#oidc-identity-provider)
    - [Add-Ons](#add-ons)
- [Argument Reference](#argument-reference)
    - [Mandatory](#mandatory)
    - [Optional](#optional)
- [Outputs](#outputs)
- [Known Limitations](#known-limitations)
    - [Editing Node Group Configuration](#editing-node-group-configuration)

## Example Usage

### Basic Usage

This example creates an EKS cluster with a one node `primary` node pool. The public API endpoint for the cluster is disabled by default, we will still be assigning multiple public subnets where the load balancers will be deployed, however.

```terraform
module "demo_eks_cluster" {
  source = "github.com/FriendsOfTerraform/aws-eks.git?ref=v1.1.0"

  name = "demo-eks"

  vpc_config = {
    subnet_ids = [
      "subnet-029fd1fxxxxxxxx", # public-us-east-1a
      "subnet-02d1ba8xxxxxxxx", # public-us-east-1b
      "subnet-0f8c5afxxxxxxxx", # public-us-east-1c
      "subnet-0e08038xxxxxxxx", # private-us-east-1a
      "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
      "subnet-0c7b976xxxxxxxx"  # private-us-east-1c
    ]
  }

  node_groups = {
    primary = {
      desired_instances  = 1

      # worker nodes should only be deployed in private subnets
      subnet_ids         = [
        "subnet-0e08038xxxxxxxx", # private-us-east-1a
        "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
        "subnet-0c7b976xxxxxxxx"  # private-us-east-1c
      ]
    }
  }
}
```

### IAM Roles For Service Accounts

This example demonstrates how to enable [IAM roles for services account][iam-role-for-service-account], which allows you to associate an IAM role to a Kubernetes service account. Please refer to [this documentation][associate-an-iam-role-to-a-service-account] to learn how to establish the association from the Kubernetes end.

```terraform
module "demo_eks_irsa" {
  source = "github.com/FriendsOfTerraform/aws-eks.git?ref=v1.1.0"

  name = "demo-eks-irsa"

  vpc_config = {
    subnet_ids = [
      "subnet-029fd1fxxxxxxxx", # public-us-east-1a
      "subnet-02d1ba8xxxxxxxx", # public-us-east-1b
      "subnet-0e08038xxxxxxxx", # private-us-east-1a
      "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
    ]
  }

  service_account_to_iam_role_mappings = {
    # Associate every service account in the `default` namespace to AmazonS3FullAccess policy
    default = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]

    # Associate the `default` service account in the `default` namespace to two policies
    "default/default" = [
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    ]
  }
}
```

### OIDC Identity Provider

This example configures an external [OIDC identity provider][oidc-idp] for authenticating to the Kubernetes API server.

```terraform
module "demo_eks_oidc" {
  source = "github.com/FriendsOfTerraform/aws-eks.git?ref=v1.1.0"

  name = "demo-eks-oidc"

  vpc_config = {
    subnet_ids = [
      "subnet-029fd1fxxxxxxxx", # public-us-east-1a
      "subnet-02d1ba8xxxxxxxx", # public-us-east-1b
      "subnet-0e08038xxxxxxxx", # private-us-east-1a
      "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
    ]
  }

  eks_oidc_identity_provider = {
    client_id      = "65a083ca-4398-450e-8cc2-af19cee7a423"
    groups_claim   = "gid:_groups"
    issuer_url     = "https://login.microsoftonline.com/8d6fb1c6-f181-4af2-928e-1c1bd4d56b5e/v2.0"
    name           = "azure-ad"
    username_claim = "email"
  }
}
```

### Add-Ons

This example demonstrates how to manage multiple [EKS add-ons][addon]. Some add-on requires additional permissions granted using service account to IAM role, those are automatically created and configured for add-ons from AWS.

```terraform
module "demo_eks_addon" {
  source = "github.com/FriendsOfTerraform/aws-eks.git?ref=v1.1.0"

  name = "demo-eks-addon"

  vpc_config = {
    subnet_ids = [
      "subnet-029fd1fxxxxxxxx", # public-us-east-1a
      "subnet-02d1ba8xxxxxxxx", # public-us-east-1b
      "subnet-0e08038xxxxxxxx", # private-us-east-1a
      "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
    ]
  }

  add_ons = {
    aws-ebs-csi-driver = { version = "v1.19.0-eksbuild.2" }
    coredns            = { version = "v1.10.1-eksbuild.1" }
    kube-proxy         = { version = "v1.27.1-eksbuild.1" }
    vpc-cni            = { version = "v1.12.6-eksbuild.2" }
  }
}
```

## Argument Reference

### Mandatory

- (string) **`name`** _[since v1.0.0]_

    The name of the EKS cluster. All associated resources will also have their name prefixed with this value

- (map(object)) **`node_groups`** _[since v1.0.0]_

    Map of worker node groups in {NodeGroupName = Config} format.

    ```terraform
    eks_node_groups = {
      "primary" = {
        desired_instances = 3
        subnet_ids = [
          "subnet-0e08038xxxxxxxx", # private-us-east-1a
          "subnet-09b6fc5xxxxxxxx", # private-us-east-1b
        ]
        kubernetes_version = "1.27"
      }
    }
    ```

    - (number) **`desired_instances`** _[since v1.0.0]_

        Number of desired worker nodes

    - (list(string)) **`subnet_ids`** _[since v1.0.0]_

        List of subnet IDs where the nodes will be deployed on. In addition, you must ensure that the subnets are tagged with the following values in order for a load balancer service to deployed successfully. Please refer to the [VPC and subnet requirements][vpc-and-subnet-requirements] for more information

      | Subnet type | Tag
      |-------------|-------------------------------------
      | public      | kubernetes.io/role/elb = 1
      | private     | kubernetes.io/role/internal-elb = 1

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the node group

    - (string) **`ami_type = "AL2_x86_64"`** _[since v1.0.0]_

        Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Please refer to [this documentation][nodegroup-datatype] for valid values

    - (string) **`ami_release_version = null`** _[since v1.0.0]_

        AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version. Please refer to this [link][ami-release-versions] for a list of the latest release versions.

    - (string) **`capacity_type = "ON_DEMAND"`** _[since v1.0.0]_

        Type of capacity associated with the EKS Node Group. Valid values are `ON_DEMAND`, `SPOT`

    - (number) **`disk_size = 20`** _[since v1.0.0]_

        EBS size for the worker nodes in GB

    - (bool) **`ignores_pod_disruption_budget = false`** _[since v1.0.0]_

        Force version update if existing pods are unable to be drained due to a pod disruption budget issue

    - (string) **`instance_type = "t3.medium"`** _[since v1.0.0]_

        [EC2 instance type][ec2-instance-type] for the worker nodes

    - (map(string)) **`kubernetes_labels = {}`** _[since v1.0.0]_

        Map of Kubernetes labels for the nodes

    - (map(string)) **`kubernetes_taints = {}`** _[since v1.0.0]_

        Map of Kubernetes taints for the nodes. In the following format: `{key = value:effect}`. Valid effects are: `NO_EXECUTE`, `NO_SCHEDULE`, `PREFER_NO_SCHEDULE`. For example

        ```
        kubernetes_taints = {foo = "bar:NO_EXECUTE"}
        ```

    - (string) **`kubernetes_version = null`** _[since v1.0.0]_

        Desired Kubernetes worker version. Refer to this page for a list of [supported versions][supported-k8s-version]. Defaults to latest version if `null`.

    - (number) **`max_instances = null`** _[since v1.0.0]_

        Number of maximum worker nodes this group can scale to. Defaults to `desired_instances` if unspecifed

    - (string) **`max_unavailable_instances_during_update = 1`** _[since v1.0.0]_

        Desired max number of unavailable worker nodes during node group update. This can be a whole number (`"2"`), or a percentage (`"50%"`)

    - (number) **`min_instances = null`** _[since v1.0.0]_

        Number of minimum worker nodes this group can scale to. Defaults to `desired_instances` if unspecifed

- (object) **`vpc_config`** _[since v1.0.0]_

    VPC configuration for the EKS cluster

    - (list(string)) **`subnet_ids`** _[since v1.0.0]_

        List of subnet IDs. Must be in at least two different availability zones. Amazon EKS creates cross-account elastic network interfaces in these subnets to allow communication between your worker nodes and the Kubernetes control plane. Please refer to the [VPC and subnet requirements][vpc-and-subnet-requirements] to make sure your VPC meets the requirement

    - (list(string)) **`security_group_ids = []`** _[since v1.0.0]_

        List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane.

### Optional

- (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

    Additional tags for the Kubernetes cluster

- (map(string)) **`additional_tags_all = {}`** _[since v1.0.0]_

    Additional tags for all resources deployed with this module

- (map(object)) **`add_ons = {}`** _[since v1.0.0]_

    Configures multiple EKS add-ons, in `{"addon_name"={CONFIGURATION}}` format. You can get a list of add-on names by running this aws cli command:

    ```bash
    aws eks describe-addon-versions | jq -r ".addons[] | .addonName"
    ```

    ```terraform
    add_ons = {
      "vpc-cni" = {
        version                     = "v1.12.6-eksbuild.2"
        resolve_conflicts_on_create = "OVERWRITE"
      }
    }
    ```

    - (map(string)) **`additional_tags = {}`** _[since v1.0.0]_

        Additional tags for the add-on

    - (string) **`configuration = null`** _[since v1.0.0]_

        Custom configuration values for add-ons with single JSON string. You can use the describe-addon-configuration call to find the correct JSON schema for each add-on. For example:

        ```bash
        aws eks describe-addon-configuration --addon-name vpc-cni --addon-version v1.12.6-eksbuild.2
        ```

    - (string) **`iam_role_arn = null`** _[since v1.0.0]_

        The arn of an existing IAM role to bind to the add-on's service account. The role must be assigned the IAM permissions required by the add-on. If you don't specify an existing IAM role, an IAM role will be created automatically for supported add-ons (see below), otherwise the add-on uses the permissions assigned to the node IAM role.

        supported add-ons: `vpc-cni`, `aws-ebs-csi-driver`, and `adot`

    - (bool) **`preserve = false`** _[since v1.0.0]_

        Indicates if you want to preserve the created resources when deleting the EKS add-on

    - (string) **`resolve_conflicts_on_create = "NONE"`** _[since v1.0.0]_

        How to resolve field value conflicts when migrating a self-managed add-on to an Amazon EKS add-on. Valid values are `"NONE"` and `"OVERWRITE"`

    - (string) **`resolve_conflicts_on_update = "NONE"`** _[since v1.0.0]_

        How to resolve field value conflicts for an Amazon EKS add-on if you've changed a value from the Amazon EKS default value. Valid values are `"NONE"` and `"OVERWRITE"`

    - (string) **`version = null`** _[since v1.0.0]_

        The version of the EKS add-on. Defaults to the latest version if `null`. You can get a list of add-on and their latest version with this command:

        ```bash
        aws eks describe-addon-versions --kubernetes-version 1.27 | jq -r ".addons[] | .addonName, .addonVersions[0].addonVersion"
        ```

- (list(string)) **`apiserver_allowed_cidrs = ["0.0.0.0/0"]`** _[since v1.0.0]_

    List of CIDR to allow access to the Kubernetes API endpoint

- (bool) **`enable_apiserver_public_endpoint = false`** _[since v1.0.0]_

    Enables the EKS public endpoint. Cluster internal traffic will still be private.

- (list(string)) **`enable_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]`** _[since v1.0.0]_

    List of the desired control plane logging to enable. [Refer to this link for valid values][eks-log-types].

- (object) **`envelope_encryption = null`** _[since v1.0.0]_

    Configures [envelope encryption][envelope-encryption] for Kubernetes secrets

    - (string) **`kms_key_arn`** _[since v1.0.0]_

        ARN of the Key Management Service (KMS) customer master key (CMK) for encryption. The CMK must be symmetric, created in the same region as the cluster, and if the CMK was created in a different account, the user must have access to the CMK.

- (object) **`kubernetes_networking_config = null`** _[since v1.0.0]_

    Configures various Kubernetes networking options

    - (string) **`kubernetes_service_address_range = null`** _[since v1.0.0]_

        The CIDR block to assign Kubernetes pod and service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks. The block must meet the following requirements:

        - Within one of the following private IP address blocks: `"10.0.0.0/8"`, `"172.16.0.0/12"`, or `"192.168.0.0/16"`
        - Doesn't overlap with any CIDR block assigned to the VPC that you selected for VPC
        - Between /24 and /12

    - (string) **`ip_family = "ipv4"`** _[since v1.0.0]_

        The IP family used to assign Kubernetes pod and service addresses. Valid values are `"ipv4"`, `"ipv6"`

- (string) **`kubernetes_version = null`** _[since v1.0.0]_

    Desired Kubernetes master version. Refer to this page for a list of [supported versions][supported-k8s-version]

- (object) **`oidc_identity_provider = null`** _[since v1.0.0]_

    Set up an EKS [OIDC identity provider][oidc-idp]

    ```terraform
    eks_oidc_identity_provider = {
      client_id      = "65a083ca-4398-450e-8cc2-af19cee7a423"
      groups_claim   = "gid:_groups"
      issuer_url     = "https://login.microsoftonline.com/8d6fb1c6-f181-4af2-928e-1c1bd4d56b5e/v2.0"
      name           = "azure-ad"
      username_claim = "email"
    }
    ```

    - (string) **`client_id`** _[since v1.0.0]_

        Client ID for the OIDC provider

    - (string) **`groups_claim`** _[since v1.0.0]_

        The JWT claim that the provider will use to return groups. This is mapped to a Kubernetes group. You can optionally prepend a prefix to this claim by separating the prefix with a `_`. eg `gid:_groups`

    - (string) **`issuer_url`** _[since v1.0.0]_

        Issuer URL for the OIDC identity provider. This URL should point to the level below [.well-known/openid-configuration][oidc-idp-issuer] and must be publicly accessible over the internet.

    - (string) **`name`** _[since v1.0.0]_

        A friendly name for this identity provider

    - (string) **`username_claim`** _[since v1.0.0]_

        The JWT claim that the provider will use as the username. This is mapped to a Kubernetes user. You can optionally prepend a prefix to this claim by separating the prefix with a `_`. eg `uid:_email`

- (map(list(string))) **`service_account_to_iam_role_mappings = {}`** _[since v1.0.0]_

    Enables and creates the [components][oidc-provider] needed for IAM roles for service accounts, then map a Kubernetes Namespace/ServiceAccount to a list of IAM policies. You can map the entire namespace to a role by omitting `<service_account>`, please see [example](#iam-roles-for-service-accounts)

    ```hcl
    {
        "<k8s_namespace>/<service_account>" = [
            "iam_policy_arn"
        ]
    }
    ```

    Where `<>` indicates a placeholder and `iam_policy_arn` is a valid ARN.

## Outputs

- (string) **`cluster_arn`** _[since v1.0.0]_

    The ARN of the EKS cluster

- (string) **`cluster_certificate_authority`** _[since v1.0.0]_

    The public CA certificate (based64) of the EKS cluster

- (string) **`cluster_endpoint_url`** _[since v1.0.0]_

    The endpoint URL of the EKS cluster

- (string) **`cluster_name`** _[since v1.1.0]_

    The name of the EKS cluster

- (string) **`cluster_role_arn`** _[since v1.1.0]_

    The ARN of the cluster IAM role

- (map(string)) **`node_group_arns`** _[since v1.0.0]_

    Map of ARNs of all the node groups associated to this cluster

- (string) **`node_role_arn`** _[since v1.1.0]_

    The ARN of the node IAM role

- (string) **`aws_cli_connect_to_cluster_command`** _[since v1.0.0]_

    The AWS cli command to connect to the EKS cluster

## Known Limitations

### Editing Node Group Configuration

Because the EKS node group is deployed using EC2 auto scaling group, updating node groups' configuration after creation will result in the creation of a new auto scaling group, effectively replacing the entire node group. However, node group replacement follows the Kubernetes node termination procedure, where all workloads will be automatically moved to the next healthy node group if available.

[addon]:https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
[addon-conflict]:https://docs.aws.amazon.com/eks/latest/userguide/add-ons-configuration.html#add-on-config-management-understanding-field-management
[ami-release-versions]:https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html
[associate-an-iam-role-to-a-service-account]:https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html
[describe-addon-versions]:https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/describe-addon-versions.html
[ec2-instance-type]:https://aws.amazon.com/ec2/instance-types/
[eks-log-types]:https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
[envelope-encryption]:https://docs.aws.amazon.com/eks/latest/userguide/enable-kms.html
[iam-role-for-service-account]:https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
[nodegroup-datatype]:https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
[oidc-idp]:https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html
[oidc-idp-issuer]:https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html#associate-oidc-identity-provider
[oidc-provider]:https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
[supported-k8s-version]:https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
[vpc-and-subnet-requirements]:https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
