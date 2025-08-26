locals {
  application_load_balancer = var.application_load_balancer != null
  gateway_load_balancer     = var.gateway_load_balancer != null
  network_load_balancer     = var.network_load_balancer != null

  common_tags = {
    managed-by = "Terraform"
  }

  port_table = {
    http  = "80",
    https = "443"
    tcp   = "80"
    tls   = "443"
    udp   = "53"
  }

  secured_protocols = ["https", "tls"]

  regex = {
    url = "^(\\w+):\\/\\/([^:\\/\\s]+[:\\d]*)([\\/\\w]*\\/[^?\\s]*)*(\\?.*)?$"
  }

  time_table = {
    second = 1
    minute = 60
    hour   = 3600
    day    = 86400
  }
}
