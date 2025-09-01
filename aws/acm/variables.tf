variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources deployed with this module"
  default     = {}
}

variable "public_certificates" {
  type = map(object({
    additional_tags           = optional(map(string), {})
    allow_export              = optional(bool, false)
    key_algorithm             = optional(string, "RSA_2048")
    subject_alternative_names = optional(list(string), null)
    validation_method         = optional(string, "DNS")
  }))
  description = "public SSL/TLS certificates from Amazon. By default, public certificates are trusted by browsers and operating systems."
  default     = {}
}
