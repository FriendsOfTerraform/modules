variable "ami" {
  type        = string
  description = "AMI ID for the instances. All generated instances will use the same AMI."
}

variable "disable_api_termination" {
  type        = bool
  description = "(Optional) If true, enables EC2 Instance Termination Protection."
  default     = true
}

variable "instance_type" {
  type        = string
  description = "Instance type/size. All generated instances will be created with the same instance type/size."
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "(Optional) AWS key pair to be associated with the instances."
  default     = null
}

variable "root_disk" {
  type        = object({
    type = string
    size = number
  })
  description = "Instance disk size in GB."
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the EC2 instance"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "monitoring" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled."
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the EC2 instance"
}

variable "key_pair" {
  type        = string
  description = "(Optional) AWS key pair to be associated with your EC2 instance. Default is set to none."
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of Security Group IDs to be associated with the instances."
}

variable "subnet_id" {
  type        = string
  description = "(Optional) The VPC Subnet ID to launch in."
}

variable "additional_ebs_volumes" {
  type = map(object({
    device_name = string
    size = number
    type = string
    provisioned_iops = optional(number)
    additional_tags = optional(map(string))
    throughput = optional(number)
  }))
}
