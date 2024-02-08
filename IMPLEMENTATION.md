# SCCA Multi Workload Expansion Module

# Table of Contents

1. [Introduction](#introduction)
1. [Architecture](#architecture)
1. [Workload Expansion Module Resources](#Worload_Expansion_Resources)
1. [Workload Expansion Module Variables](#Workload_Expansion_Variables)
1. [Deployment Samples](#samples)


# <a name="introduction"></a>1. Introduction

SCCA Workload Expansion Module allows customers to deploy additional workload into an existing SCCA LZ environment. The Workload expansion module is responsible for deploying Compartment, Network (VCN), Logging, Monitoring, and Workload related IAM resources. The SCCA LZ will set up one initial workload configuration. If, in the future, customers need a separate Workload stack, they can use this module to deploy a workload stack. 

# <a name="architecture"></a>2. Architecture

![Architecture](<./images/SCCA-CA.png> "Architecture")

This architecture diagram illustrates the resources SCCA LZ deploys and Workload Expansion Resources are defined in the L2 Workload Section.

# <a name="Workload Expansion Module Resources"></a>3. Workload Expansion Module Resources

The workload expansion module is responsible for deploying the below-defined resources in an empty workload, as depicted as L2 Workload 2 in the Architecture Diagram. 

* Workload Compartment.
* Network.
* Monitoring.
* Workload IAM and Policies.
* VTAP(Optional).
* Load Balancer(Optional).

## 3.1 : Workload Compartment

The workload Expansion Module will create one compartment using the naming syntax, starting with the workload_compartment_name variable and ending with mission_owner_key variable.

## 3.2 : Network

The workload Expansion Module will create two separate networks("VCN"), one for workload application use and another for Database resources. Following two VCN will be created and they will acting as spoke to Baseline VCN as Hub.

### 3.2.1 : Workload Application Network

This is a "Spoke" VCN for workload applications. This VCN is connected to Baseline VCN & Network Firewall via DRG. It contain one user-customizable subnet which is connected to workload load balancer.

### 3.2.2 : Workload Database Network

This is an additional "Spoke" network for workload applications to allow greater isolation for potentially sensitive databases.This VCN is connected to Baseline VCN & Network Firewall via DRG. It contain one user-customizable subnet which is connected to workload load balancer.

## 3.3 : Monitoring

The workload expansion Monitoring Module defines a small set of rules to actively and passively monitor workload resources using the Metrics and Alarms features. The Workload Alarms have two priorities: CRITICAL for high-importance events and WARNING for more informational events. This module will define 11 Critical Alarms and 6 Warning Alarms, and the customer can enable critical, warning, or both alarms as per their requirements.

## 3.4 : Workload IAM and Policies

The workload expansion module will define one workload Admin group under the Baseline SCCA LZ identity domain and set of policies to monitor all workload resources.

## 3.5 : VTAP

The workload expansion module will optionally deploy a VTAP on the Workload networks. A VTAP is a cloud resource that can clone network traffic from any source on the same VCN, filter it appropriately, then forward it on to applications such network security, packet collectors, or network analytics packages. The traffic will be encapsulated as per VXLAN protocol data plane, and sent on UDP port 4789. By Default VTAP creation boolen flag set to false. If customer want to enable VTAP they need to enable load balancer as well.

## 3.6 : Load Balancer

If the Customer enables VTAP, the workload expansion module will create a Network Load Balancer(NLB), which will load balance traffic per lower-level network traffic details. NLB is pre-configured to listen to VxLAN traffic, i.e., UDP Port 4789. Customer can configure the server(s) for their network security, analytics, or logging applications as backends on this NLB.


# <a name="Workload Expansion Module Variables"></a>4. Workload Expansion Module Variables

## 4.1 : Workload Compartment Related Variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="workload_compartment_name"></a> [workload\_compartment\_name](#workload\_compartment\_name)   | Provide Workload Compartment Name Starting Prefix | `string` | `"OCI-SCCA-LZ-Workload"`    | 
| <a name="mission_owner_key"></a> [mission\_owner\_key](#mission\_owner\_key)   | Provide Workload Compartment Name Ending Prefix | `string` | `NA`    |
| <a name="home_compartment_id"></a> [home\_compartment\_id](#home\_compartment\_id])   | Provide Baseline Home Compartment OCID Value  | `string` | `NA`    | 
| <a name="vdms_compartment_name"></a> [vdms\_compartment\_name](#vdms\_compartment\_name)   | Provide Baseline VDMS Compartment Name  | `string` | `NA`    | 


## 4.2 : Network Related Variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="workload_vcn_cidr_block"></a> [workload\_vcn\_cidr\_block](#workload\_vcn\_cidr\_block)   | Provide Workload VCN IP CIDR Block | `string` | `"192.170.0.0/16"`    | 
| <a name="workload_vcn_dns_label"></a> [workload\_vcn\_dns\_label](#workload\_vcn\_dns\_label)   | Provide Workload VCN DNS Label | `string` | `"wrkvcndns"`    | 
| <a name="workload_subnet_cidr"></a> [workload\_subnet\_cidr](#workload\_vcn\_cidr\_block)   | Provide Workload VCN Subnet IP CIDR | `string` | `"192.170.1.0/24"`    | 
| <a name="workload_subnet_dns_label"></a> [workload\_subnet\_dns\_label](#workload\_vcn\_cidr\_block)   | Provide Workload VCN Subnet DNS Label | `string` | `"wrkdns"`    | 
| <a name="workload_db_vcn_cidr_block"></a> [workload\_db\_vcn\_cidr\_block](#workload\_db\_vcn\_cidr\_block)   | Provide Workload DB VCN IP CIDR Block | `string` | `"192.171.0.0/16"`    | 
| <a name="workload_db_dns_label"></a> [workload\_db\_dns\_label](#workload\_db\_dns\_label)   | Provide Workload DB VCN DNS Label | `string` | `"wrkdb"`    | 
| <a name="workload_db_subnet_cidr_block"></a> [workload\_db\_subnet\_cidr\_block](#workload\_db\_subnet\_cidr\_block)   | Provide Workload DB VCN Subnet IP CIDR Block | `string` | `"192.171.0.0/16"`    | 
| <a name="workload_db_subnet_dns_label"></a> [workload\_db\_subnet\_dns\_label](#workload\_db\_subnet\_dns\_label)   | Provide Workload DB VCN DNS Label | `string` | `"dbsubnet"`    | 
| <a name="vdss_vcn_cidr_block"></a> [vdss\_vcn\_cidr\_block](#vdss\_vcn\_cidr\_block)   | Provide Baseline VDSS VCN CIDR Block | `string` | `NA`    | 
| <a name="vdms_vcn_cidr_block"></a> [vdms\_vcn\_cidr\_block](#vdms\_vcn\_cidr\_block)   | Provide Baseline VDMS VCN CIDR Block | `string` | `NA`    | 
| <a name="drg_id"></a> [drg\_id](#drg\_id)   | Provide Baseline DRG OCID Value | `string` | `NA`    | 


## 4.3 : Monitoring Related Variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="enable_workload_critical_alarm"></a> [enable\_workload\_critical\_alarm](#enable\_workload\_critical\_alarm)   | Enable Workload Critical Alarms | `boolean` | `false`    | 
| <a name="enable_workload_warning_alarm"></a> [enable\_workload\_warning\_alarm](#enable\_workload\_warning\_alarm)   | Enable Workload Warning Alarms | `boolean` | `false`    | 
| <a name="workload_warning_topic_endpoints"></a> [workload\_warning\_topic\_endpoints](#workload\_warning\_topic\_endpoints)   | Provide Email Address for Warning Notifications | `list` | `Empty List`    | 
| <a name="workload_critical_topic_endpoints"></a> [workload\_critical\_topic\_endpoints](#workload\_critical\_topic\_endpoints)   | Provide Email Address for Critical Notifications | `list` | `Empty List`    | 

## 4.4 : Workload IAM and Policies Related Variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="identity_domain_name"></a> [identity\_domain\_name](#identity\_domain\_name)   | Provide Baseline Identity Domain Name | `string` | `NA`    |
| <a name="idcs_endpoint"></a> [idcs\_endpoint](#idcs\_endpoint)   | Provide Baseline Identity Domain IDCS Endpoint | `string` | `NA`    |
| <a name="mission_owner_workload_admin_group"></a> [mission\_owner\_workload\_admin\_group](#mission\_owner\_workload\_admin\_group)   | Provide Workload Admin Group Name | `string` | `"WORKLOAD-TEST-ADMIN"`    |
| <a name="master_encryption_key_ocid"></a> [master\_encryption\_key\_ocid](#master\_encryption\_key\_ocid)   | Provide Baseline Master Encryption Key OCID Value | `string` | `NA`    | 

## 4.5 : VTAP & NLB Related Variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="enable_workload_load_balancer"></a> [enable\_workload\_load\_balancer](#enable\_workload\_load\_balancer)   | Enable Load Balancer on Workload | `boolean` | `true`    | 
| <a name="enable_workload_vtap"></a> [enable\_workload\_vtap](#enable\_workload\_vtap)   | Enable VTAP on Workload | `boolean` | `false`    |


# <a name="Deployment Samples"></a>5. Deployment Samples

This section will provide deployment of the Workload Expansion Module on the existing Baseline SCCA LZ using Terraform CLI.

## 5.1 : OCI Tenancy and User Related variables

| Variable Name      | Description| Type | Default
| ------------------- | ----- | ----- | ----- |
| <a name="tenancy_ocid"></a> [tenancy\_ocid](#tenancy\_ocid)   | Provide OCI Tenancy OCID Value | `string` | ``    | 
| <a name="current_user_ocid"></a> [current\_user\_ocid](#current\_user\_ocid)   | Provide Current User OCID Value | `string` | ``    | 
| <a name="region"></a> [region](#region)   | Provide OCI Home Region Name | `string` | ``    | 
| <a name="api_fingerprint"></a> [api\_fingerprint](#api\_fingerprint)   | Provide API Fingerprint | `string` | ``    | 
| <a name="api_private_key_path"></a> [api\_private\_key\_path](#api\_private\_key\_path)   | Provide  | `string` | ``    | 


## 5.2 : Deploying Workload Expansion Module on top of SCCA LZ.

* Step 1) Go to Baseline SCCA and deploy the SCCA LZ.<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform init<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform plan -var-file="example.tfvars" -out baseline_scca.out<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform apply baseline_scca.out<br />
* Step 2) Provide variable value on workload.tfvars as per Section 4 and Section 5.1.
* Step 3) Execute the Following Command.<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform init<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform plan -var-file="workload.tfvars" -out workload_first.out<br />
 &nbsp;&nbsp;&nbsp;&nbsp;terraform apply workload_first.out<br />
* Step 4) Go to the Baseline SCCA LZ and update variable workload_additionalsubnets_cidr_blocks with new Workload and Workload DB VCN Subnet CIDR Block.Execute the Following Command.<br />
&nbsp;&nbsp;&nbsp;&nbsp;terraform plan -var-file="example.tfvars" -out baseline_scca_add_workload_cidr.out<br />
&nbsp;&nbsp;&nbsp;&nbsp;terraform apply baseline_scca_add_workload_cidr.out<br />

## 5.3 : Delete Workload Expansion Module on top of SCCA LZ.

* Step 1) Go to Workload Expansion SCCA and execute the following command.<br />
&nbsp;&nbsp;&nbsp;&nbsp;terraform destroy<br />





