locals {
  instances_to_create = {
    for instance in keys(var.instances_to_create) :
    tostring(index(keys(var.instances_to_create), instance)) => {
      name   = instance,
      subnet = var.instances_to_create[instance]
    }
  }
}

resource "aws_instance" "ec2_instance" {
    for_each = local.instances_to_create

    ami                     = var.ami
    disable_api_termination = var.disable_api_termination
    key_name                = var.key_name
    instance_type           = var.instance_type
    monitoring              = var.monitoring
    vpc_security_group_ids  = var.security_group_ids   
}