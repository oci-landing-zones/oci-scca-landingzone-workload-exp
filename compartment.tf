locals {
  workload_compartment = {
    name        = "${var.workload_compartment_name}-${local.region_key[0]}-${var.mission_owner_key}"
    description = "SCCA Workload Expansion"
  }
}

module "workload_compartment" {
  source = "./modules/compartment"

  compartment_parent_id     = var.home_compartment_id
  compartment_name          = local.workload_compartment.name
  compartment_description   = local.workload_compartment.description
  enable_compartment_delete = var.enable_compartment_delete
}