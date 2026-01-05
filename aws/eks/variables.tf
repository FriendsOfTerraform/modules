variable "name" {
  type        = string
  description = <<EOT
    The name of the Kubernetes cluster. All associated resources will also have their name prefixed with this value

    @since 1.0.0
  EOT
}

variable "node_groups" {
  type = map(object({
    /// Number of desired worker nodes
    ///
    /// @since 1.0.0
    desired_instances = number

    /// List of subnet IDs where the nodes will be deployed on. In addition, you must ensure that the subnets are tagged
    /// with the following values in order for a load balancer service to deployed successfully.
    ///
    /// Public subnets: kubernetes.io/role/elb = 1
    /// Private subnets: kubernetes.io/role/internal-elb = 1
    ///
    /// @link "VPC and Subnet Requirements" https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    /// @since 1.0.0
    subnet_ids = list(string)

    /// Additional tags for the node group
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    ///
    /// @enum AL2_x86_64|AL2_x86_64_GPU|AL2_ARM_64|CUSTOM|BOTTLEROCKET_ARM_64|BOTTLEROCKET_x86_64|BOTTLEROCKET_ARM_64_FIPS|BOTTLEROCKET_x86_64_FIPS|BOTTLEROCKET_ARM_64_NVIDIA|BOTTLEROCKET_x86_64_NVIDIA|WINDOWS_CORE_2019_x86_64|WINDOWS_FULL_2019_x86_64|WINDOWS_CORE_2022_x86_64|WINDOWS_FULL_2022_x86_64|AL2023_x86_64_STANDARD|AL2023_ARM_64_STANDARD|AL2023_x86_64_NEURON|AL2023_x86_64_NVIDIA|AL2023_ARM_64_NVIDIA
    /// @link "Valid AMI Types" https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
    /// @since 1.0.0
    ami_type = optional(string, "AL2_x86_64")

    /// AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version.
    ///
    /// @link "Latest AMI Release Versions" https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html
    /// @since 1.0.0
    ami_release_version = optional(string, null)

    /// Type of capacity associated with the EKS Node Group
    ///
    /// @enum ON_DEMAND|SPOT
    /// @since 1.0.0
    capacity_type = optional(string, "ON_DEMAND")

    /// EBS size for the worker nodes in GB
    ///
    /// @since 1.0.0
    disk_size = optional(number, 20)

    /// Force version update if existing pods are unable to be drained due to a pod disruption budget issue
    ///
    /// @since 1.0.0
    ignores_pod_disruption_budget = optional(bool, false)

    /// [EC2 instance type][ec2-instance-type] for the worker nodes
    ///
    /// @link {ec2-instance-type} https://aws.amazon.com/ec2/instance-types/
    /// @since 1.0.0
    instance_type = optional(string, "t3.medium")

    /// Map of Kubernetes labels for the nodes
    ///
    /// @since 1.0.0
    kubernetes_labels = optional(map(string), {})

    /// Map of Kubernetes taints for the nodes. In the following format: `{key = value:effect}`.
    ///
    /// @enum NO_EXECUTE|NO_SCHEDULE|PREFER_NO_SCHEDULE
    /// @since 1.0.0
    kubernetes_taints = optional(map(string), {})

    /// Desired Kubernetes worker version. Defaults to latest version if null
    ///
    /// @link "Supported Kubernetes Versions" https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
    /// @since 1.0.0
    kubernetes_version = optional(string, null)

    /// Number of maximum worker nodes this group can scale to. Defaults to `desired_instances` if unspecified
    ///
    /// @since 1.0.0
    max_instances = optional(number, null)

    /// Desired max number of unavailable worker nodes during node group update
    /// This can be a whole number or a percentage (e.g., "50%")
    ///
    /// @since 1.0.0
    max_unavailable_instances_during_update = optional(string, "1")

    /// Number of minimum worker nodes this group can scale to. Defaults to `desired_instances` if unspecified
    ///
    /// @since 1.0.0
    min_instances = optional(number, null)
  }))
  description = <<EOT
    Map of worker node groups

    @example "Basic Usage" #basic-usage
    @since 1.0.0
  EOT
}

variable "vpc_config" {
  type = object({
    /// List of subnet IDs. Must be in at least two different availability zones.
    /// Amazon EKS creates cross-account elastic network interfaces in these subnets to allow communication
    /// between your worker nodes and the Kubernetes control plane.
    ///
    /// @link "VPC and Subnet Requirements" https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    /// @since 1.0.0
    subnet_ids = list(string)

    /// List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates
    /// to use to allow communication between your worker nodes and the Kubernetes control plane
    ///
    /// @since 1.0.0
    security_group_ids = optional(list(string), [])
  })
  description = <<EOT
    VPC configuration for the EKS cluster

    @since 1.0.0
  EOT
}

variable "additional_tags" {
  type        = map(string)
  description = <<EOT
    Additional tags for the Kubernetes cluster

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

variable "add_ons" {
  type = map(object({
    /// Additional tags for the add-on
    ///
    /// @since 1.0.0
    additional_tags = optional(map(string), {})

    /// Custom configuration values for add-ons with single JSON string. You can use the describe-addon-configuration call to find the correct JSON schema for each add-on. For example:
    ///
    /// ```bash
    /// aws eks describe-addon-configuration --addon-name vpc-cni --addon-version v1.12.6-eksbuild.2
    /// ```
    ///
    /// @since 1.0.0
    configuration = optional(string, null)

    /// The arn of an existing IAM role to bind to the add-on's service account.
    /// The role must be assigned the IAM permissions required by the add-on. If
    /// you don't specify an existing IAM role, an IAM role will be created
    /// automatically for supported add-ons (see below), otherwise the add-on
    /// uses the permissions assigned to the node IAM role.
    ///
    /// Supported add-ons: `vpc-cni`, `aws-ebs-csi-driver`, and `adot`
    ///
    /// @since 1.0.0
    iam_role_arn = optional(string, null)

    /// Indicates if you want to preserve the created resources when deleting the EKS add-on
    ///
    /// @since 1.0.0
    preserve = optional(bool, false)

    /// How to resolve field value conflicts when migrating a self-managed add-on to an Amazon EKS add-on
    ///
    /// @enum NONE|OVERWRITE
    /// @since 1.0.0
    resolve_conflicts_on_create = optional(string, "NONE")

    /// How to resolve field value conflicts for an Amazon EKS add-on if you've changed a value from the Amazon EKS default value
    ///
    /// @enum NONE|OVERWRITE
    /// @since 1.0.0
    resolve_conflicts_on_update = optional(string, "NONE")

    /// The version of the EKS add-on. Defaults to the latest version if null
    ///
    /// You can get a list of add-on and their latest version with this command:
    ///
    /// ```bash
    /// aws eks describe-addon-versions --kubernetes-version 1.27 | jq -r ".addons[] | .addonName, .addonVersions[0].addonVersion"
    /// ```
    ///
    /// @since 1.0.0
    version = optional(string, null)
  }))
  description = <<EOT
    Configures multiple EKS add-ons.

    You can get a list of add-on names by running this aws cli command:

    ```bash
    aws eks describe-addon-versions | jq -r ".addons[] | .addonName"
    ```

    @example "Add-Ons Example" #add-ons
    @since 1.0.0
  EOT
  default     = {}
}

variable "apiserver_allowed_cidrs" {
  type        = list(string)
  description = <<EOT
    List of CIDR blocks that can access the Amazon EKS public API server endpoint

    @since 1.0.0
  EOT
  default     = ["0.0.0.0/0"]
}

variable "enable_apiserver_public_endpoint" {
  type        = bool
  description = <<EOT
    Enables the EKS public endpoint. Cluster internal traffic will still be private

    @since 1.0.0
  EOT
  default     = false
}

variable "enable_cluster_log_types" {
  type        = list(string)
  description = <<EOT
    List of the desired control plane logging types to enable

    @link "Valid EKS Log Types" https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
    @since 1.0.0
  EOT
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "envelope_encryption" {
  type = object({
    /// ARN of the Key Management Service (KMS) customer master key (CMK) for encryption.
    /// The CMK must be symmetric, created in the same region as the cluster, and if the CMK was created in a different account,
    /// the user must have access to the CMK
    ///
    /// @since 1.0.0
    kms_key_arn = string
  })
  description = <<EOT
    Configures envelope encryption for Kubernetes secrets

    @link {envelope-encryption} https://docs.aws.amazon.com/eks/latest/userguide/enable-kms.html
    @since 1.0.0
  EOT
  default     = null
}

variable "kubernetes_networking_config" {
  type = object({
    /// The CIDR block to assign Kubernetes pod and service IP addresses from.
    /// If you don't specify a block, Kubernetes assigns addresses from either
    /// the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks. The block must meet the
    /// following requirements:
    ///
    /// - Within one of the following private IP address blocks: `"10.0.0.0/8"`, `"172.16.0.0/12"`, or `"192.168.0.0/16"`
    /// - Doesn't overlap with any CIDR block assigned to the VPC that you selected for VPC
    /// - Between /24 and /12
    ///
    /// @since 1.0.0
    kubernetes_service_address_range = optional(string, null)

    /// The IP family used to assign Kubernetes pod and service addresses
    ///
    /// @enum ipv4|ipv6
    /// @since 1.0.0
    ip_family = optional(string, "ipv4")
  })
  description = <<EOT
    Configures various Kubernetes networking options

    @since 1.0.0
  EOT
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = <<EOT
    Desired Kubernetes master version. Defaults to latest version if null

    @link "Supported Kubernetes Versions" https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
    @since 1.0.0
  EOT
  default     = null
}

variable "oidc_identity_provider" {
  type = object({
    /// Client ID for the OIDC provider
    ///
    /// @since 1.0.0
    client_id = string

    /// The JWT claim that the provider will use to return groups. This is mapped to a Kubernetes group.
    /// You can optionally prepend a prefix to this claim by separating the prefix with a `_`. eg `gid:_groups`
    ///
    /// @since 1.0.0
    groups_claim = string

    /// Issuer URL for the OIDC identity provider. This URL should point to the
    /// level below [.well-known/openid-configuration][oidc-idp-issuer] and must
    /// be publicly accessible over the internet
    ///
    /// @link {oidc-idp-issuer} https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html#associate-oidc-identity-provider
    /// @since 1.0.0
    issuer_url = string

    /// A friendly name for this identity provider
    ///
    /// @since 1.0.0
    name = string

    /// The JWT claim that the provider will use as the username. This is mapped to a Kubernetes user.
    /// You can optionally prepend a prefix to this claim by separating the prefix with a `_`. eg `uid:_email`
    ///
    /// @since 1.0.0
    username_claim = string
  })
  description = <<EOT
    Set up an EKS [OIDC identity provider][oidc-idp] for authenticating to the Kubernetes API server

    @example "OIDC Identity Provider" #oidc-identity-provider
    @link {oidc-idp} https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html
    @since 1.0.0
  EOT
  default     = null
}

variable "service_account_to_iam_role_mappings" {
  type        = map(list(string))
  description = <<EOT
    Enables and creates the [components][oidc-provider] needed for IAM roles for
    service accounts, then map a Kubernetes Namespace/ServiceAccount to a list of
    IAM policies. You can map the entire namespace to a role by omitting
    `<service_account>`.

    @example "IAM Roles For Service Accounts" #iam-roles-for-service-accounts
    @link {oidc-provider} https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
    @since 1.0.0
  EOT
  default     = {}
}
