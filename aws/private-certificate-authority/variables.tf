variable "subject" {
  type = object({
    common_name       = string
    country           = optional(string)
    locality          = optional(string)
    organization      = optional(string)
    organization_unit = optional(string)
    state             = optional(string)
  })
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the CA"
  default     = {}
}

variable "additional_tags_all" {
  type        = map(string)
  description = "Additional tags for all resources in deployed with this module"
  default     = {}
}

variable "authorize_acm_access_to_renew_certificates" {
  type        = bool
  description = "Allow ACM to issue and renew ACM certificates that reside in the same Amazon Web Services account as the CA"
  default     = true
}

variable "ca_type" {
  type        = string
  description = "Specify the type of the certificate authority."
  default     = "ROOT"
}

variable "crl_configuration" {
  type = object({
    create_s3_bucket = optional(object({
      bucket_name       = string
      additional_tags   = optional(map(string), {})
      enable_versioning = optional(bool, false)
    }))
    custom_crl_name  = optional(string)
    enabled          = optional(bool, true)
    s3_bucket_name   = optional(string)
    validity_in_days = optional(number, 7)
  })
  description = "Option to set up CRL distribution"
  default     = null
}

variable "key_algorithm" {
  type        = string
  description = "Type of the public key algorithm and size, in bits, of the key pair that your CA creates when it issues a certificate. When you create a subordinate CA, you must use a key algorithm supported by the parent CA."
  default     = "RSA_2048"
}

variable "ocsp_configuration" {
  type = object({
    custom_ocsp_endpoint = optional(string)
    enabled              = optional(bool, true)
  })
  description = "Sets up an OCSP server for this CA"
  default     = null
}

variable "policy" {
  type        = string
  description = "Text of the private CA policy document to attach"
  default     = null
}

variable "signing_algorithm" {
  type        = string
  description = "Name of the algorithm your private CA uses to sign certificate requests."
  default     = "SHA256WITHRSA"
}

variable "subordinate_ca_configuration" {
  type = object({
    import_certificate = optional(object({
      certificate       = string
      certificate_chain = string
    }))
    parent_ca_arn = optional(string)
    path_length   = optional(number, 0)
  })
  description = "Sepcify options to setup a subordinate CA"
  default     = null
}

variable "usage_mode" {
  type        = string
  description = "Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly. Short-lived certificate validity is limited to seven days."
  default     = "GENERAL_PURPOSE"
}

variable "validity" {
  type        = string
  description = "Specify the validity period of the CA certificate"
  default     = "10 years"
}
