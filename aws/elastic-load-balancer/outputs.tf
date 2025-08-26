output "load_balancer" {
  value = {
    arn      = aws_lb.load_balancer.arn
    dns_name = aws_lb.load_balancer.dns_name
    zone_id  = aws_lb.load_balancer.zone_id
  }
}

output "application_load_balancer_listeners" {
  value = local.application_load_balancer ? { for k, v in var.application_load_balancer.listeners : k => {
    arn = aws_lb_listener.application_load_balancer_listeners[k].arn
  } } : {}
}

output "gateway_load_balancer_listeners" {
  value = local.gateway_load_balancer ? { for k, v in var.gateway_load_balancer.listener : k => {
    arn = aws_lb_listener.gateway_load_balancer_listener[0].arn
  } } : {}
}

output "network_load_balancer_listeners" {
  value = local.network_load_balancer ? { for k, v in var.network_load_balancer.listeners : k => {
    arn = aws_lb_listener.network_load_balancer_listeners[k].arn
  } } : {}
}
