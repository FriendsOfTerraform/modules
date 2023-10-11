locals {
  instances_to_create = {
    for instance in keys(var.instances_to_create) :
    tostring(index(keys(var.instances_to_create), instance)) => {
      name   = instance,
      subnet = var.instances_to_create[instance]
    }
  }
}
