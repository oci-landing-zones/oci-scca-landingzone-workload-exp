locals {
  identity_domain = {
    domain_description        = "OCI SCCA Landing Zone Identity Domain"
    domain_display_name       = "OCI-SCCA-LZ-Domain-${local.region_key[0]}-${var.mission_owner_key}"
    domain_license_type       = "premium"
    domain_is_hidden_on_login = false

    group_names = [var.mission_owner_workload_admin_group]
  }
}

module "identity_domain" {
  source                    = "./modules/identity-domain"
  compartment_id            = var.home_compartment_id
  domain_description        = local.identity_domain.domain_description
  domain_display_name       = local.identity_domain.domain_display_name
  domain_license_type       = local.identity_domain.domain_license_type
  domain_is_hidden_on_login = local.identity_domain.domain_is_hidden_on_login
  domain_home_region        = var.region
}

module "workload_admin_group" {
  source             = "./modules/identity-domains-groups"
  group_display_name = var.mission_owner_workload_admin_group
  idcs_endpoint      = module.identity_domain.domain.url
}


locals {
  workload_policy = {
    name        = "OCI-SCCA-LZ-Workload-Policy"
    description = "This account is required for the management of the Mission Application workloads."
    statements = [
      "Allow group ${local.identity_domain.domain_display_name}/${var.mission_owner_workload_admin_group} to manage all-resources in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${local.identity_domain.domain_display_name}/${var.mission_owner_workload_admin_group} to use key-delegate in compartment ${var.vdms_compartment_name}-${local.region_key[0]}-${var.resource_label} where target.key.id = ${var.master_encryption_key_ocid}"
    ]
  }
}

module "workload_policy" {
  source           = "./modules/policies"
  compartment_ocid = var.home_compartment_id
  policy_name      = local.workload_policy.name
  description      = local.workload_policy.description
  statements       = local.workload_policy.statements
}