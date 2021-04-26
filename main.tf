#get the data fro the global vars WS
data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = "CiscoDevNet"
    workspaces = {
      name = var.globalwsname
    }
  }
}

# Intersight Provider Information 
terraform {
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      version = "1.0.5"
    }
  }
}



variable "api_key" {
  type        = string
  description = "API Key"
}
variable "secretkey" {
  type        = string
  description = "Secret Key"
}
variable "globalwsname" {
  type        = string
  description = "TFC WS from where to get the params"
}
variable "mgmtcfgsshkeys" {
  type        = string
  description = "sshkeys"
}


provider "intersight" {
  apikey        = var.api_key
  secretkey = var.secretkey
  endpoint      = "https://intersight.com"
}

data "intersight_organization_organization" "organization_moid" {
  name = local.organization
}

output "organization_moid" {
  value = data.intersight_organization_organization.organization_moid.results.0.moid
}


# IPPool moids
data "intersight_ippool_pool" "ippool_moid" {
  name  = local.ippool_list
}

# Netcfg moids
#data "intersight_kubernetes_network_policy" "netcfg_moid" {
#  name  = local.netcfg_list
#}

# Sysconfig moids
#data "intersight_kubernetes_sys_config_policy" "syscfg_moid" {
#  name  = local.syscfg_list
#}



locals {
  organization= yamldecode(data.terraform_remote_state.global.outputs.organization)
  ippool_list = yamldecode(data.terraform_remote_state.global.outputs.ippool_list)
  netcfg_list = yamldecode(data.terraform_remote_state.global.outputs.network_pod)
  syscfg_list = yamldecode(data.terraform_remote_state.global.outputs.network_service)
  clustername = yamldecode(data.terraform_remote_state.global.outputs.clustername)
  mgmtcfgetcd = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfgetcd)
  mgmtcfglbcnt = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfglbcnt)
  mgmtcfgsshuser = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfgsshuser)
  ippoolmaster_list = yamldecode(data.terraform_remote_state.global.outputs.ippool_list)
  ippoolworker_list = yamldecode(data.terraform_remote_state.global.outputs.ippool_list)
  kubever_list = yamldecode(data.terraform_remote_state.global.outputs.k8s_version_name)
  infrapolname = yamldecode(data.terraform_remote_state.global.outputs.infrapolname)
  instancetypename = yamldecode(data.terraform_remote_state.global.outputs.instancetypename)
  mastergrpname = yamldecode(data.terraform_remote_state.global.outputs.mastergrpname)
  masterdesiredsize = yamldecode(data.terraform_remote_state.global.outputs.masterdesiredsize)
  masterinfraname = yamldecode(data.terraform_remote_state.global.outputs.masterinfraname)
}



