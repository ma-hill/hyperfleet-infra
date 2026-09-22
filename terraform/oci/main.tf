module "ci_compartment" {
  source                = "../modules/compartment/oci"
  parent_compartment_id = var.team_compartment_id
  freeform_tags         = local.tags
}

module "ci_quota" {
  source       = "../modules/quota/oci"
  tenancy_ocid = var.tenancy_ocid
  statements   = var.quota_statements

  freeform_tags = local.tags

  depends_on = [module.ci_compartment]
}

module "ci_budget" {
  source                = "../modules/budget/oci"
  tenancy_ocid          = var.tenancy_ocid
  target_compartment_id = module.ci_compartment.id
  amount                = var.budget_amount
  alert_recipients      = var.budget_alert_recipients

  freeform_tags = local.tags
}

module "dns_compartment" {
  count = var.dns_enabled ? 1 : 0

  source                = "../modules/compartment/oci"
  parent_compartment_id = var.team_compartment_id
  name                  = var.dns_compartment_name
  description           = var.dns_compartment_description
  freeform_tags         = var.dns_freeform_tags
  enable_delete         = false
}

module "dns" {
  count = var.dns_enabled ? 1 : 0

  source = "../modules/dns/oci"

  compartment_id = module.dns_compartment[0].id
  zone_name      = var.dns_zone_name
  freeform_tags  = var.dns_freeform_tags
}

resource "oci_identity_dynamic_group" "external_dns" {
  count = var.dns_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = var.external_dns_dynamic_group_name
  description    = var.external_dns_dynamic_group_description
  matching_rule  = var.external_dns_dynamic_group_matching_rule
  freeform_tags  = var.dns_freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_identity_policy" "external_dns" {
  count = var.dns_enabled ? 1 : 0

  compartment_id = var.dns_compartment_id
  name           = var.external_dns_policy_name
  description    = var.external_dns_policy_description
  freeform_tags  = var.dns_freeform_tags
  statements = concat(
    [
      "allow dynamic-group ${var.external_dns_dynamic_group_name} to manage dns in compartment id ${var.dns_compartment_id}",
    ],
    var.external_dns_policy_statements,
  )

  lifecycle {
    prevent_destroy = true
  }
}

# The DNS compartment, zone, dynamic group, and policy already exist. Their
# OCIDs and current definitions are supplied in private tfvars before enabling
# DNS management, so Terraform adopts rather than recreates them.
import {
  for_each = var.dns_enabled ? toset(["dns-compartment"]) : toset([])

  to = module.dns_compartment[0].oci_identity_compartment.this
  id = var.dns_compartment_id
}

import {
  for_each = var.dns_enabled ? toset(["dns-zone"]) : toset([])

  to = module.dns[0].oci_dns_zone.this
  id = var.dns_zone_id
}

import {
  for_each = var.dns_enabled ? toset(["external-dns-dynamic-group"]) : toset([])

  to = oci_identity_dynamic_group.external_dns[0]
  id = var.external_dns_dynamic_group_id
}

import {
  for_each = var.dns_enabled ? toset(["external-dns-policy"]) : toset([])

  to = oci_identity_policy.external_dns[0]
  id = var.external_dns_policy_id
}

module "ci_sweep" {
  source                = "../modules/lifecycle/oci"
  tenancy_ocid          = var.tenancy_ocid
  compartment_id        = module.ci_compartment.id
  function_image        = var.sweep_function_image
  function_image_digest = var.sweep_function_image_digest

  run_window_hours    = var.sweep_run_window_hours
  dry_run             = var.sweep_dry_run
  schedule_recurrence = var.sweep_schedule_recurrence

  freeform_tags = local.tags
}

resource "terraform_data" "postgresql_regional_durability_check" {
  count = var.postgresql_enabled ? 1 : 0

  lifecycle {
    precondition {
      condition     = !(var.postgresql_storage_is_regionally_durable && var.region == "us-sanjose-1")
      error_message = "postgresql_storage_is_regionally_durable cannot be true in us-sanjose-1 (single availability domain). Set to false or use a multi-AD region."
    }
  }
}

module "managed_postgresql" {
  count = var.postgresql_enabled ? 1 : 0

  source            = "../modules/postgresql/oci"
  compartment_id    = var.postgresql_compartment_id
  ci_compartment_id = module.ci_compartment.id
  tenancy_ocid      = var.tenancy_ocid
  subnet_id         = var.postgresql_subnet_id

  display_name                  = var.postgresql_display_name
  db_version                    = var.postgresql_db_version
  shape                         = var.postgresql_shape
  instance_ocpu_count           = var.postgresql_instance_ocpu_count
  instance_memory_size_in_gbs   = var.postgresql_instance_memory_size_in_gbs
  instance_count                = var.postgresql_instance_count
  availability_domain           = var.postgresql_availability_domain
  storage_is_regionally_durable = var.postgresql_storage_is_regionally_durable
  admin_username                = var.postgresql_admin_username
  admin_password_secret_id      = var.postgresql_admin_password_secret_id
  admin_password_secret_version = var.postgresql_admin_password_secret_version
  nsg_ids                       = var.postgresql_nsg_ids
  backup_retention_days         = var.postgresql_backup_retention_days
  backup_start                  = var.postgresql_backup_start

  freeform_tags = {
    "hyperfleet-managed-by" = "terraform"
    "hyperfleet-purpose"    = "oci-deployment-path-postgresql"
  }

  depends_on = [terraform_data.postgresql_regional_durability_check]
}

locals {
  tags = {
    "hyperfleet-managed-by" = "terraform"
    "hyperfleet-purpose"    = "ci"
  }
}
