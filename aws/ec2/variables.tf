variable "instances_to_create" {
  type        = map(string)
  description = "Number of instance replica."
}

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

variable "root_disk_size" {
  type        = number
  description = "Instance disk size in GB. Default is set to 20GB"
  default     = 20
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for EC2 instance"
  default     = {}
}

variable "monitoring" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled."
  default     = false
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