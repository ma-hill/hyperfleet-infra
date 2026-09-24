output "ci_compartment_id" {
  description = "OCID of the hyperfleet-ci compartment."
  value       = module.ci_compartment.id
}

output "dns_zone_id" {
  description = "OCID of the imported DNS zone, or null when DNS is disabled."
  value       = try(module.dns[0].zone_id, null)
}

output "dns_nameservers" {
  description = "Authoritative OCI nameservers for the imported DNS zone."
  value       = try(module.dns[0].nameservers, [])
}

output "sweep_container_repository_path" {
  description = "OCIR repository path to push the sweep function's image to."
  value       = module.ci_sweep.container_repository_path
}

output "sweep_function_id" {
  description = "OCID of the deployed sweep function."
  value       = module.ci_sweep.function_id
}

output "postgresql_id" {
  description = "OCID of the managed PostgreSQL db system, if postgresql_enabled is true."
  value       = try(module.managed_postgresql[0].id, null)
}

output "postgresql_primary_db_endpoint_private_ip" {
  description = "Private IP of the managed PostgreSQL db system's primary endpoint, if postgresql_enabled is true."
  value       = try(module.managed_postgresql[0].primary_db_endpoint_private_ip, null)
}

output "oke_lb_nsg_policy_id" {
  description = "OCID of the OKE load balancer NSG policy, if oke_lb_nsg_policy_enabled is true."
  value       = try(module.oke_lb_nsg_policy[0].policy_id, null)
}
