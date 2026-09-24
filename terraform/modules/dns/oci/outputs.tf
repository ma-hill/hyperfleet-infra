output "zone_id" {
  description = "OCID of the DNS zone."
  value       = oci_dns_zone.this.id
}

output "zone_name" {
  description = "DNS zone name."
  value       = oci_dns_zone.this.name
}

output "nameservers" {
  description = "Authoritative OCI nameservers for the zone."
  value       = oci_dns_zone.this.nameservers[*].hostname
}
