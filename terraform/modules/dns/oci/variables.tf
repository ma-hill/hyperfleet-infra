variable "compartment_id" {
  description = "OCID of the compartment that owns the DNS zone."
  type        = string
}

variable "zone_name" {
  description = "Public DNS zone name, without a trailing dot."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags applied to the DNS zone."
  type        = map(string)
  default     = {}
}
