# ###################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

locals {
  workload_critical_topic = {
    topic_name            = "Workload-Expansion-Critical-${var.mission_owner_key}"
    topic_description     = "Critical notification for Workload"
    subscription_protocol = "EMAIL"
  }
  workload_warning_topic = {
    topic_name            = "Workload-Expansion-Warning-${var.mission_owner_key}"
    topic_description     = "Warning notification for Workload"
    subscription_protocol = "EMAIL"
  }
}


module "workload_critical_topic" {
  source = "./modules/notification-topic"

  compartment_id        = module.workload_compartment.compartment_id
  topic_name            = local.workload_critical_topic.topic_name
  topic_description     = local.workload_critical_topic.topic_description
  subscription_endpoint = var.workload_critical_topic_endpoints
  subscription_protocol = local.workload_critical_topic.subscription_protocol
}


module "workload_warning_topic" {
  source = "./modules/notification-topic"

  compartment_id        = module.workload_compartment.compartment_id
  topic_name            = local.workload_warning_topic.topic_name
  topic_description     = local.workload_warning_topic.topic_description
  subscription_endpoint = var.workload_warning_topic_endpoints
  subscription_protocol = local.workload_warning_topic.subscription_protocol
}

# -----------------------------------------------------------------------------
# Alarms
# -----------------------------------------------------------------------------


locals {
  workload_critical_alarms = {
    metric_compartment_id_in_subtree = false
    is_enabled                       = var.enable_workload_critical_alarm
    message_format                   = "ONS_OPTIMIZED"
    pending_duration                 = "PT5M"

    alarm_map = {
      compute_instance_status_alarm = {
        display_name          = "compute_instance_status_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_compute_infrastructure_health"
        query                 = "instance_status[1m].sum() > 0"
        severity              = "CRITICAL"
      }
      compute_vm_instance_status_alarm = {
        display_name          = "compute_vm_instance_status_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_compute_infrastructure_health"
        query                 = "maintenance_status[1m].sum() > 0"
        severity              = "CRITICAL"
      }
      compute_bare_metal_unhealthy_alarm = {
        display_name          = "compute_bare_metal_unhealthy_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_compute_infrastructure_health"
        query                 = "health_status[1m].count() > 0"
        severity              = "CRITICAL"
      }
      compute_high_compute_alarm = {
        display_name          = "compute_high_compute_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_computeagent"
        query                 = "CpuUtilization[1m].mean() > 80"
        severity              = "CRITICAL"
      }
      compute_high_memory_alarm = {
        display_name          = "compute_high_memory_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_computeagent"
        query                 = "MemoryUtilization[1m].mean() > 80"
        severity              = "CRITICAL"
      }
      database_adb_cpu_alarm = {
        display_name          = "database_adb_cpu_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_autonomous_database"
        query                 = "CpuUtilization[1m].mean() > 80"
        severity              = "CRITICAL"
      }
      database_adb_storage_alarm = {
        display_name          = "database_adb_storage_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_autonomous_database"
        query                 = "StorageUtilization[1m].mean() > 80"
        severity              = "CRITICAL"
      }
      network_lbUnHealthyBackendServers_alarm = {
        display_name          = "network_lbUnHealthyBackendServers_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_lbaas"
        query                 = "UnHealthyBackendServers[1m].mean() > 0"
        severity              = "CRITICAL"
      }
      network_lbFailedSSLClientCertVerify_alarm = {
        display_name          = "network_lbFailedSSLClientCertVerify_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_lbaas"
        query                 = "FailedSSLClientCertVerify[1m].mean() > 0"
        severity              = "CRITICAL"
      }
      network_lbFailedSSLHandshake_alarm = {
        display_name          = "network_lbFailedSSLHandshake_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_lbaas"
        query                 = "FailedSSLHandshake[1m].mean() > 0"
        severity              = "CRITICAL"
      }
      network_vcnVnicConntrackIsFull_alarm = {
        display_name          = "network_vcnVnicConntrackIsFull_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_vcn"
        query                 = "VnicConntrackIsFull[1m].mean() > 0"
        severity              = "CRITICAL"
      }
    }
  }

  workload_warning_alarms = {
    metric_compartment_id_in_subtree = false
    is_enabled                       = var.enable_workload_warning_alarm
    message_format                   = "ONS_OPTIMIZED"
    pending_duration                 = "PT5M"

    alarm_map = {
      objectstorage_UncommittedParts_alarm = {
        display_name          = "objectstorage_UncommittedParts_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_objectstorage"
        query                 = "UncommittedParts[1m].count() > 0"
        severity              = "WARNING"
      }
      objectstorage_ClientErrors_alarm = {
        display_name          = "objectstorage_ClientErrors_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_objectstorage"
        query                 = "ClientErrors[1m].sum() > 0"
        severity              = "WARNING"
      }
      network_lbPeakBandwidth_alarm = {
        display_name          = "network_lbPeakBandwidth_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_lbaas"
        query                 = "PeakBandwidth[1m].mean() < 8"
        severity              = "WARNING"
      }
      network_vcnVnicConntrackUtilPercent_alarm = {
        display_name          = "network_vcnVnicConntrackUtilPercent_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_vcn"
        query                 = "VnicConntrackUtilPercent[1m].mean() > 80"
        severity              = "WARNING"
      }
      network_vcnVnicEgressDropThrottle_alarm = {
        display_name          = "network_vcnVnicEgressDropThrottle_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_vcn"
        query                 = "VnicEgressDropThrottle[1m].mean() > 0"
        severity              = "WARNING"
      }
      network_vcnVnicIngressDropThrottle_alarm = {
        display_name          = "network_vcnVnicIngressDropThrottle_alarm"
        metric_compartment_id = module.workload_compartment.compartment_id
        namespace             = "oci_vcn"
        query                 = "VnicIngressDropThrottle[1m].mean() > 0"
        severity              = "WARNING"
      }
    }
  }
}

module "workload_critical_alarms" {
  source = "./modules/alarm"

  compartment_id                   = module.workload_compartment.compartment_id
  notification_topic_id            = module.workload_critical_topic.topic_id
  is_enabled                       = local.workload_critical_alarms.is_enabled
  message_format                   = local.workload_critical_alarms.message_format
  pending_duration                 = local.workload_critical_alarms.pending_duration
  metric_compartment_id_in_subtree = local.workload_critical_alarms.metric_compartment_id_in_subtree
  alarm_map                        = local.workload_critical_alarms.alarm_map
}

module "workload_warning_alarms" {
  source = "./modules/alarm"

  compartment_id                   = module.workload_compartment.compartment_id
  notification_topic_id            = module.workload_warning_topic.topic_id
  is_enabled                       = local.workload_warning_alarms.is_enabled
  message_format                   = local.workload_warning_alarms.message_format
  pending_duration                 = local.workload_warning_alarms.pending_duration
  metric_compartment_id_in_subtree = local.workload_warning_alarms.metric_compartment_id_in_subtree
  alarm_map                        = local.workload_warning_alarms.alarm_map
}
