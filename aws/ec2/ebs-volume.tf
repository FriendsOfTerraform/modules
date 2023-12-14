data "aws_subnet" "root_network_interface_subnet" {
  id = var.network_interface.subnet_id
}

resource "aws_ebs_volume" "additional_ebs_volumes" {
  for_each = var.additional_ebs_volumes

  availability_zone = data.aws_subnet.root_network_interface_subnet.availability_zone
  encrypted         = each.value.kms_key_id != null
  final_snapshot    = each.value.final_snapshot
  iops              = each.value.provisioned_iops
  kms_key_id        = each.value.kms_key_id
  size              = each.value.size
  snapshot_id       = each.value.snapshot_id
  throughput        = each.value.throughput
  type              = each.value.volume_type

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

resource "aws_volume_attachment" "additional_volume_attachments" {
  for_each = var.additional_ebs_volumes

  device_name  = each.value.device_name
  instance_id  = aws_instance.ec2_instance.id
  volume_id    = aws_ebs_volume.additional_ebs_volumes[each.key].id
  force_detach = true
  skip_destroy = !each.value.delete_on_termination
}
