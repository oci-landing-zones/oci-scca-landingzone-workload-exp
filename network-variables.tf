variable "workload_vcn_cidr_block" {
  description = "Workload VCN CIDR Block"
  type    = string
  default = "192.170.1.0/24"
}

variable "workload_subnet_cidr" {
  description = "Workload Subnet CIDR Block"
  type    = string
  default = "192.170.1.0/24"
}

variable "workload_subnet_dns_label" {
  description = "Workload Subnet DNS Label"
  type    = string
  default = "wrkdns"
}

variable "workload_db_vcn_cidr_block" {
  description = "Workload Subnet CIDR Block"
  type    = string
  default = "192.170.2.0/24"
}

variable "workload_db_dns_label" {
  description = "Workload Subnet DNS Label"
  type    = string
  default = "wrkdbdns"
}
variable "drg_id" {
  type    = string
  validation {
    condition     = can(regex("^drg$", split(".", var.drg_id)[1]))
    error_message = "Only DRG OCID is allowed."
  }
}
variable "vdss_vcn_cidr_block" {
  description = "Workload Subnet CIDR Block"
  type    = string
  default = "192.170.2.0/24"
}
variable "vdms_vcn_cidr_block" {
  description = "Workload Subnet CIDR Block"
  type    = string
  default = "192.170.2.0/24"
}
variable "enable_workload_load_balancer" {
  type    = bool
  default = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.enable_workload_load_balancer))
    error_message = "The enable_workload_load_balancer Flag variable must be either true or false."
  }
}
variable "enable_workload_vtap" {
  type    = bool
  default = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.enable_workload_vtap))
    error_message = "The enable_workload_vtap Flag variable must be either true or false."
  }
}