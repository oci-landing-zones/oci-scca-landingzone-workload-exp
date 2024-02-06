# ###################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "mission_owner_key" {
  type        = string
  description = "The unique label used to avoid naming conflicts"
}

variable "workload_compartment_name" {
  type        = string
  description = "Name of the SCCA Landing Zone Workload compartment."
  default     = "OCI-SCCA-LZ-Workload"
}

variable "home_compartment_id" {
  type        = string
  description = "The OCID of SCCA Landing Zone Home compartment"
}

variable "enable_compartment_delete" {
  type        = bool
  description = "Set to true to allow the compartments to delete on terraform destroy."
  default     = true
}