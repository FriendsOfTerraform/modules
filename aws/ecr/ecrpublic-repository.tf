resource "aws_ecrpublic_repository" "public_repositories" {
  for_each = var.public_registry != null ? var.public_registry.repositories : {}

  repository_name = each.key

  catalog_data {
    about_text        = each.value.about_text
    architectures     = each.value.architectures
    description       = each.value.description
    logo_image_blob   = each.value.logo_image_blob
    operating_systems = each.value.operating_systems
    usage_text        = each.value.usage_text
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
