locals {
  certificate_revocation_lists_to_create = flatten([
    for listener_name, listener in local.trust_stores_to_create : [
      for k, v in listener.enable_mutual_authentication.verify_with_trust_store.new_trust_store.certificate_revocation_lists : {
        listener_name = listener_name
        s3_bucket     = regex(local.regex.url, k)[1]
        s3_key        = trimprefix(regex(local.regex.url, k)[2], "/")
        version       = v.version
      }
    ]
  ])
}

resource "aws_lb_trust_store_revocation" "certificate_revocation_lists" {
  for_each = tomap({ for certificate_revocation_list in local.certificate_revocation_lists_to_create : "${certificate_revocation_list.listener_name}-${certificate_revocation_list.s3_bucket}-${certificate_revocation_list.s3_key}" => certificate_revocation_list })

  trust_store_arn = aws_lb_trust_store.trust_stores[each.value.listener_name].arn

  revocations_s3_bucket         = each.value.s3_bucket
  revocations_s3_key            = each.value.s3_key
  revocations_s3_object_version = each.value.version
}
