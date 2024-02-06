# ###################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

locals {
  workload_policy = {
    name        = "OCI-SCCA-LZ-Workload-Policy-${var.mission_owner_key}"
    description = "This account is required for the management of the Mission Application workloads with label ${var.mission_owner_key}"
    statements = [
      "Allow group ${var.identity_domain_name}/${var.mission_owner_workload_admin_group} to manage all-resources in compartment ${module.workload_compartment.compartment_name}",
      "Allow group ${var.identity_domain_name}/${var.mission_owner_workload_admin_group} to use key-delegate in compartment ${var.vdms_compartment_name} where target.key.id = ${var.master_encryption_key_ocid}"
    ]
  }
}

module "workload_admin_group" {
  source             = "./modules/identity-domains-groups"
  group_display_name = var.mission_owner_workload_admin_group
  idcs_endpoint      = var.idcs_endpoint
}

module "workload_policy" {
  source           = "./modules/policies"
  compartment_ocid = var.home_compartment_id
  policy_name      = local.workload_policy.name
  description      = local.workload_policy.description
  statements       = local.workload_policy.statements
}