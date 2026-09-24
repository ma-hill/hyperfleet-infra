resource "oci_dns_zone" "this" {
  compartment_id = var.compartment_id
  name           = var.zone_name
  zone_type      = "PRIMARY"
  scope          = "GLOBAL"
  freeform_tags  = var.freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}
