# ###################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #
variable "tenancy_ocid" {
  type        = string
  description = "the OCID of tenancy"
}

variable "region" {
  type        = string
  description = "Region the resources will be deployed in"
}

variable "mission_owner_workload_admin_group" {
  type        = string
  description = "Name of the Mission Owner Workload Admin user group"
}

variable "idcs_endpoint" {
  type        = string
  description = "URL endpoint of the existing identity domain"
}

variable "identity_domain_name" {
  type        = string
  description = "Identity domain display name"
}

variable "master_encryption_key_ocid" {
  type        = string
  description = "OCID of the master encryption key"
}

variable "vdms_compartment_name" {
  type        = string
  description = "Full name of the VDMS compartment, including region key"
}
