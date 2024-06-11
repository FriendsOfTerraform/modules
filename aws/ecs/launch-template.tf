# Queries the inputted images to determine the device name for block mapping
data "aws_ami" "images" {
  for_each = var.ec2_capacity_providers

  filter {
    name   = "image-id"
    values = [each.value.image_id]
  }
}

# Generate launch templates to build the EC2 clusters
resource "aws_launch_template" "launch_templates" {
  for_each = var.ec2_capacity_providers

  image_id               = each.value.image_id
  instance_type          = each.value.instance_type
  key_name               = each.value.ssh_keypair_name
  name                   = "${aws_ecs_cluster.ecs_cluster.name}-${each.key}-launch-template" # The name is a combination of <cluster_name>-<capacity_provider_name>-launch-template
  vpc_security_group_ids = each.value.security_group_ids

  user_data = data.aws_ami.images[each.key].platform == "windows" ? (
    base64encode(templatefile("${path.module}/userdata/windows.sh", { cluster_name = aws_ecs_cluster.ecs_cluster.name }))
  ) : base64encode(templatefile("${path.module}/userdata/linux.sh", { cluster_name = aws_ecs_cluster.ecs_cluster.name }))

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )

  block_device_mappings {
    device_name = tolist(data.aws_ami.images[each.key].block_device_mappings[*].device_name)[0]

    ebs {
      volume_size = each.value.root_ebs_volume_size
    }
  }

  iam_instance_profile {
    arn = each.value.instance_iam_role != null ? aws_iam_instance_profile.instance_profiles[each.key].arn : aws_iam_instance_profile.default_ecs_role_profile[0].arn
  }
}
