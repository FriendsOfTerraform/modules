resource "aws_ecr_repository" "private_repositories" {
  for_each = var.private_registry != null ? var.private_registry.repositories : {}

  name                 = each.key
  force_delete         = each.value.force_delete
  image_tag_mutability = each.value.enable_tag_immutability ? "IMMUTABLE" : "MUTABLE"

  encryption_configuration {
    encryption_type = each.value.encrypt_with_kms != null ? "KMS" : "AES256"
    kms_key         = each.value.encrypt_with_kms != null ? each.value.encrypt_with_kms.kms_key_id : null
  }

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}
