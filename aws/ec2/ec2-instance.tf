resource "aws_instance" "ec2_instance" {
    ami                     = var.ami
    disable_api_termination = var.disable_api_termination
    key_name                = var.key_name
    instance_type           = var.instance_type
    monitoring              = var.monitoring
    vpc_security_group_ids  = var.security_group_ids
    subnet_id               = var.subnet_id

  root_block_device {
    volume_type = var.root_disk.type
    volume_size = var.root_disk.size
  }

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all,
    {
      Name = var.name
    }
  )
}

// additional ebs volume
resource "aws_ebs_volume" "ebs_volumes" {
  for_each = var.additional_ebs_volumes 
  availability_zone = data.aws_subnet.subnet.availability_zone
  iops = each.value.provisioned_iops
  size = each.value.size
  type = each.value.type
  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all,
    {
      Name = each.key
    }
  )
}

resource aws_volume_attachment "ebs_volume_attachment" {
  for_each = var.additional_ebs_volumes
  device_name = each.value.device_name
  volume_id = aws_ebs_volume.ebs_volumes[each.key].id
  instance_id = aws_instance.ec2_instance.id
}
