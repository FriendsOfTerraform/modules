output "load_balancer" {
  description = <<EOT
    Info for this load balancer

    @type object({
      /// The ARN of the load balancer
      ///
      /// @since 1.0.0
      arn = string

      /// DNS name of the load balancer
      ///
      /// @since 1.0.0
      dns_name = string

      /// Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record).
      ///
      /// @since 1.0.0
      zone_id = string
    })
    @since 1.0.0
  EOT
  value = {
    arn      = aws_lb.load_balancer.arn
    dns_name = aws_lb.load_balancer.dns_name
    zone_id  = aws_lb.load_balancer.zone_id
  }
}

output "application_load_balancer_listeners" {
  description = <<EOT
    Info for the listeners if `application_load_balancer` is specified

    @type map(object({
      /// The ARN of the listener
      ///
      /// @since 1.0.0
      arn = string
    }))
    @since 1.0.0
  EOT
  value = local.application_load_balancer ? { for k, v in var.application_load_balancer.listeners : k => {
    arn = aws_lb_listener.application_load_balancer_listeners[k].arn
  } } : {}
}

output "gateway_load_balancer_listeners" {
  description = <<EOT
    Info for the listeners if `gateway_load_balancer` is specified

    @type map(object({
      /// The ARN of the listener
      ///
      /// @since 1.0.0
      arn = string
    }))
    @since 1.0.0
  EOT
  value = local.gateway_load_balancer ? { for k, v in var.gateway_load_balancer.listener : k => {
    arn = aws_lb_listener.gateway_load_balancer_listener[0].arn
  } } : {}
}

output "network_load_balancer_listeners" {
  description = <<EOT
    Info for the listeners if `network_load_balancer` is specified

    @type map(object({
      /// The ARN of the listener
      ///
      /// @since 1.0.0
      arn = string
    }))
    @since 1.0.0
  EOT
  value = local.network_load_balancer ? { for k, v in var.network_load_balancer.listeners : k => {
    arn = aws_lb_listener.network_load_balancer_listeners[k].arn
  } } : {}
}
