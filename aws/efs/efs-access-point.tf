resource "aws_efs_access_point" "access_points" {
  for_each = var.access_points

  file_system_id = aws_efs_file_system.efs.id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [1] : []

    content {
      gid            = each.value.posix_user.group_id
      secondary_gids = each.value.posix_user.secondary_group_ids
      uid            = each.value.posix_user.user_id
    }
  }

  root_directory {
    dynamic "creation_info" {
      for_each = each.value.root_directory_creation_permissions != null ? [1] : []

      content {
        owner_gid   = each.value.root_directory_creation_permissions.owner_group_id
        owner_uid   = each.value.root_directory_creation_permissions.owner_user_id
        permissions = each.value.root_directory_creation_permissions.access_point_permissions
      }
    }

    path = each.value.root_directory_path
  }

  tags = merge(
    { Name = each.key },
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
