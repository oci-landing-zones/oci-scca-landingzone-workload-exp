# -----------------------------------------------------------------------------
# Create Workload  Resources
# -----------------------------------------------------------------------------
locals {
  wrk_network = {
    name                     = "${var.workload_compartment_name}-VCN-${local.region_key[0]}-${var.mission_owner_key}"
    vcn_dns_label            = var.workload_vcn_dns_label
    lockdown_default_seclist = false
    subnet_map = {
      OCI-SCCA-LZ-Workload-SUB = {
        name                       = "${var.workload_compartment_name}-Wrk-${local.region_key[0]}-${var.mission_owner_key}"
        description                = "WORKLOAD Subnet"
        dns_label                  = var.workload_subnet_dns_label
        cidr_block                 = var.workload_subnet_cidr
        prohibit_public_ip_on_vnic = true
      }
    }
  }
  wrk_db_network = {
    name                     = "${var.workload_compartment_name}-Wrk-DB-VCN-${local.region_key[0]}-${var.mission_owner_key}"
    vcn_dns_label            = var.workload_db_dns_label
    lockdown_default_seclist = false
    subnet_map = {
      OCI-SCCA-LZ-Workload-DB-SUB = {
        name                       = "${var.workload_compartment_name}-Wrk-DB-${local.region_key[0]}-${var.mission_owner_key}"
        description                = "WORKLOAD DB Subnet"
        dns_label                  = var.workload_db_dns_label
        cidr_block                 = var.workload_db_vcn_cidr_block
        prohibit_public_ip_on_vnic = true
      }
    }
  }

  workload_vdss_sgw = {
    sgw_display_name         = "OCI-SCCA-VDSS-VCN-WRK-${local.region_key[0]}-SGW"
    service_id               = data.oci_core_services.all_oci_services.services[0]["id"]
    route_table_display_name = "WRKSGW-RT"
    route_rules = {
      "all-to-nfw" = {
        network_entity_id = var.drg_id
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
      }
    }
  }
  workload_route_table = {
    Workload-VCN-Egress = {
      route_table_display_name = "${var.workload_compartment_name}-VCN-Egress"
      subnet_id                = module.workload_network.subnets[local.wrk_network.subnet_map["OCI-SCCA-LZ-Workload-SUB"].name]
      subnet_name              = "OCI-SCCA-LZ-Workload-SUB"
      route_rules = {
        "vdss" = {
          network_entity_id = var.drg_id
          destination       = var.vdss_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "vdms" = {
          network_entity_id = var.drg_id
          destination       = var.vdms_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "workload_db" = {
          network_entity_id = var.drg_id
          destination       = var.workload_db_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "all_service" = {
          network_entity_id = var.drg_id
          destination       = data.oci_core_services.all_oci_services.services[0]["cidr_block"]
          destination_type  = "SERVICE_CIDR_BLOCK"
        }
      }
    }
  }

  workload_db_route_table = {
    Workload-DB-VCN-Egress = {
      route_table_display_name = "${var.workload_compartment_name}-DB-VCN-Egress"
      subnet_id                = module.workload_db_network.subnets[local.wrk_db_network.subnet_map["OCI-SCCA-LZ-Workload-DB-SUB"].name]
      subnet_name              = "OCI-SCCA-LZ-Workload-DB-SUB"
      route_rules = {
        "vdss" = {
          network_entity_id = var.drg_id
          destination       = var.vdss_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "vdms" = {
          network_entity_id = var.drg_id
          destination       = var.vdms_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "workload" = {
          network_entity_id = var.drg_id
          destination       = var.workload_vcn_cidr_block
          destination_type  = "CIDR_BLOCK"
        }
        "all_service" = {
          network_entity_id = var.drg_id
          destination       = data.oci_core_services.all_oci_services.services[0]["cidr_block"]
          destination_type  = "SERVICE_CIDR_BLOCK"
        }
      }
    }
  }
  workload_vtap = {
    vtap_display_name           = "${var.workload_compartment_name}-VTAP-${local.region_key[0]}-${var.mission_owner_key}"
    vtap_source_type            = "LOAD_BALANCER"
    capture_filter_display_name = "WORKLOAD-VTAP-Capture-Filter"
    vtap_capture_filter_rules = {
      "allow-all" = {
        traffic_direction = "INGRESS"
        rule_action       = "INCLUDE"
      }
    }
    nlb_display_name     = "WORKLOAD-VTAP-NLB"
    nlb_listener_name    = "WORKLOAD-VTAP-NLB-LISTENER"
    nlb_backend_set_name = "WORKLOAD-VTAP-NLB-BACKEND-SET"
  }
  workload_load_balancer = {
    lb_name   = "${var.workload_compartment_name}-LB-${local.region_key[0]}-${var.mission_owner_key}"
    lb_subnet = module.workload_network.subnets[local.wrk_network.subnet_map["OCI-SCCA-LZ-Workload-SUB"].name]
  }
}  

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All [A-Za-z0-9]+ Services In Oracle Services Network"]
    regex  = true
  }
}

module "workload_network" {
  source = "./modules/vcn"

  vcn_cidr_block           = var.workload_vcn_cidr_block
  compartment_id           = module.workload_compartment.compartment_id
  vcn_display_name         = local.wrk_network.name
  vcn_dns_label            = local.wrk_network.vcn_dns_label
  lockdown_default_seclist = local.wrk_network.lockdown_default_seclist
  subnet_map               = local.wrk_network.subnet_map
}

module "workload_db_network" {
  source = "./modules/vcn"

  vcn_cidr_block           = var.workload_db_vcn_cidr_block
  compartment_id           = module.workload_compartment.compartment_id
  vcn_display_name         = local.wrk_db_network.name
  vcn_dns_label            = local.wrk_db_network.vcn_dns_label
  lockdown_default_seclist = local.wrk_db_network.lockdown_default_seclist
  subnet_map               = local.wrk_db_network.subnet_map
}

module "workload_route_table" {
  source = "./modules/route-table"

  for_each                 = local.workload_route_table
  compartment_id           = module.workload_compartment.compartment_id
  route_table_display_name = each.value.route_table_display_name
  route_rules              = each.value.route_rules
  vcn_id                   = module.workload_network.vcn_id
  subnet_id                = each.value.subnet_id
  subnet_name              = each.value.subnet_name
}

module "workload_db_route_table" {
  source = "./modules/route-table"

  for_each                 = local.workload_db_route_table
  compartment_id           = module.workload_compartment.compartment_id
  route_table_display_name = each.value.route_table_display_name
  route_rules              = each.value.route_rules
  vcn_id                   = module.workload_db_network.vcn_id
  subnet_id                = each.value.subnet_id
  subnet_name              = each.value.subnet_name
}

module "workload_load_balancer" {
  count  = var.enable_workload_load_balancer ? 1 : 0
  source = "./modules/load-balancer"

  compartment_id             = module.workload_compartment.compartment_id
  load_balancer_display_name = local.workload_load_balancer.lb_name
  load_balancer_subnet_ids   = [local.workload_load_balancer.lb_subnet]
  load_balancer_is_private   = true
  lb_add_waf                 = true
  lb_add_waa                 = true
}

module "workload_vtap" {
  count  = var.enable_workload_vtap ? 1 : 0
  source = "./modules/vtap"

  compartment_id              = module.workload_compartment.compartment_id
  vtap_source_type            = local.workload_vtap.vtap_source_type
  vtap_source_id              = module.workload_load_balancer[0].lb_id
  vcn_id                      = module.workload_network.vcn_id
  vtap_display_name           = local.workload_vtap.vtap_display_name
  vtap_capture_filter_rules   = local.workload_vtap.vtap_capture_filter_rules
  is_vtap_enabled             = var.enable_workload_vtap
  capture_filter_display_name = local.workload_vtap.capture_filter_display_name
  nlb_display_name            = local.workload_vtap.nlb_display_name
  nlb_subnet_id               = module.workload_network.subnets[local.wrk_network.subnet_map["OCI-SCCA-LZ-Workload-SUB"].name]
  nlb_listener_name           = local.workload_vtap.nlb_listener_name
  nlb_backend_set_name        = local.workload_vtap.nlb_backend_set_name
}


module "wrk_vdss_sgw" {
  source = "./modules/vcn-gateways"

  compartment_id           = module.workload_compartment.compartment_id
  service_id               = local.workload_vdss_sgw.service_id
  sgw_display_name         = local.workload_vdss_sgw.sgw_display_name
  route_table_display_name = local.workload_vdss_sgw.route_table_display_name
  route_rules              = local.workload_vdss_sgw.route_rules
  vcn_id                   = module.workload_network.vcn_id
}

module "workload_vcn_drg_attachment" {
  source                        = "./modules/drg-attachment"
  drg_id                        = var.drg_id
  vcn_id                        = module.workload_db_network.vcn_id
  drg_attachment_type           = "VCN"
  drg_attachment_vcn_route_type = "VCN_CIDRS"
}
module "workload_db_vcn_drg_attachment" {
  source                        = "./modules/drg-attachment"
  drg_id                        = var.drg_id
  vcn_id                        = module.workload_network.vcn_id
  drg_attachment_type           = "VCN"
  drg_attachment_vcn_route_type = "VCN_CIDRS"
}