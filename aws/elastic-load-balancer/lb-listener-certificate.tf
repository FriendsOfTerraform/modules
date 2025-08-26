locals {
  application_load_balancer_listener_certificates = local.application_load_balancer ? flatten([
    for listener_name, listener in var.application_load_balancer.listeners : [
      for certificate in listener.certificates_for_sni : {
        listener_name   = listener_name
        certificate_arn = certificate
      }
    ]
  ]) : []

  network_load_balancer_listener_certificates = local.network_load_balancer ? flatten([
    for listener_name, listener in var.network_load_balancer.listeners : [
      for certificate in listener.certificates_for_sni : {
        listener_name   = listener_name
        certificate_arn = certificate
      }
    ]
  ]) : []
}

resource "aws_lb_listener_certificate" "application_load_balancer_listener_certificates" {
  for_each = tomap({ for certificate in local.application_load_balancer_listener_certificates : "${certificate.listener_name}-${certificate.certificate_arn}" => certificate })

  listener_arn    = aws_lb_listener.application_load_balancer_listeners[each.value.listener_name].arn
  certificate_arn = each.value.certificate_arn
}

resource "aws_lb_listener_certificate" "network_load_balancer_listener_certificates" {
  for_each = tomap({ for certificate in local.network_load_balancer_listener_certificates : "${certificate.listener_name}-${certificate.certificate_arn}" => certificate })

  listener_arn    = aws_lb_listener.network_load_balancer_listeners[each.value.listener_name].arn
  certificate_arn = each.value.certificate_arn
}
