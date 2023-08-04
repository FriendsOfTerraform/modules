locals {
  static_website_hosting_enabled = var.static_website_hosting_config != null ? (
    var.static_website_hosting_config.static_website != null ? true : (
      var.static_website_hosting_config.redirect_requests_for_an_object != null ? true : false
    )
  ) : false

  static_website_enabled    = local.static_website_hosting_enabled ? var.static_website_hosting_config.static_website != null : false
  redirect_requests_enabled = local.static_website_hosting_enabled ? var.static_website_hosting_config.redirect_requests_for_an_object != null : false
}

resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  count = local.static_website_hosting_enabled ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  dynamic "error_document" {
    for_each = local.static_website_enabled ? (
      var.static_website_hosting_config.static_website.error_document != null ? [1] : []
    ) : []

    content {
      key = var.static_website_hosting_config.static_website.error_document
    }
  }

  expected_bucket_owner = var.bucket_owner_account_id

  dynamic "index_document" {
    for_each = local.static_website_enabled ? (
      var.static_website_hosting_config.static_website.index_document != null ? [1] : []
    ) : []

    content {
      suffix = var.static_website_hosting_config.static_website.index_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = local.redirect_requests_enabled ? [1] : []

    content {
      host_name = var.static_website_hosting_config.redirect_requests_for_an_object.host_name
      protocol  = var.static_website_hosting_config.redirect_requests_for_an_object.protocol
    }
  }
}