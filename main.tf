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
      version = "1.0.11"
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
data "intersight_kubernetes_network_policy" "netcfg_moid" {
  name  = local.netcfg_list
}

# Sysconfig moids
data "intersight_kubernetes_sys_config_policy" "syscfg_moid" {
  name  = local.syscfg_list
}


# kube cluster profiles
resource "intersight_kubernetes_cluster_profile" "kubeprof" {
  name = local.clustername 
  wait_for_completion=false
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.organization_moid.results.0.moid
  }
  cluster_ip_pools {
	object_type = "ippool.Pool" 
	moid = data.intersight_ippool_pool.ippool_moid.results.0.moid
  }
  management_config {
#	encrypted_etcd = local.mgmtcfgetcd
	load_balancer_count = local.mgmtcfglbcnt
	ssh_keys = [ 
		 var.mgmtcfgsshkeys
	]
	ssh_user = local.mgmtcfgsshuser
	object_type = "kubernetes.ClusterManagementConfig" 
  }
  net_config {
	moid = data.intersight_kubernetes_network_policy.netcfg_moid.results.0.moid
	object_type = "kubernetes.NetworkPolicy" 
  }

  sys_config {
	moid = data.intersight_kubernetes_sys_config_policy.syscfg_moid.results.0.moid
	object_type = "kubernetes.SysConfigPolicy" 
  }
}



# IpPool moids
data "intersight_ippool_pool" "ippoolmaster_moid" {
  name  = local.ippoolmaster_list
}

# IpPool moids
data "intersight_ippool_pool" "ippoolworker_moid" {
  name  = local.ippoolworker_list
}

# Kube version moids
data "intersight_kubernetes_version_policy" "kubever_moid" {
  name  = local.kubever_list
}

# Infra Config Policy
data "intersight_kubernetes_virtual_machine_infra_config_policy" "infrapol" {
  name  = local.infrapolname
}

# Instance Type
data "intersight_kubernetes_virtual_machine_instance_type" "instancetype" {
  name  = local.instancetypename
}

# Master
resource "intersight_kubernetes_node_group_profile" "masternodegrp" {
  name = local.mastergrpname
  node_type = "ControlPlaneWorker"
  desiredsize = local.masterdesiredsize

  ip_pools {
        object_type = "ippool.Pool" 
        moid = data.intersight_ippool_pool.ippoolmaster_moid.results.0.moid
  }


  cluster_profile {
        object_type = "kubernetes.ClusterProfile" 
        moid = intersight_kubernetes_cluster_profile.kubeprof.moid
  }


  kubernetes_version {
        object_type = "kubernetes.VersionPolicy" 
        moid = data.intersight_kubernetes_version_policy.kubever_moid.results.0.moid
  }

}

#Infra provider
resource "intersight_kubernetes_virtual_machine_infrastructure_provider" "masterinfraprov" {
	name = local.masterinfraname
	infra_config_policy {
		moid =  data.intersight_kubernetes_virtual_machine_infra_config_policy.infrapol.results.0.moid
		object_type = "kubernetes.VirtualMachineInfraConfigPolicy"
	}
	instance_type {
		moid =  data.intersight_kubernetes_virtual_machine_instance_type.instancetype.results.0.moid
		object_type = "kubernetes.VirtualMachineInstanceType"
	}
	node_group {
		moid = intersight_kubernetes_node_group_profile.masternodegrp.moid 
		object_type = "kubernetes.NodeGroupProfile"
	}

}


resource "intersight_kubernetes_cluster_profile" "kubeprofaction" {
  depends_on = [
        intersight_kubernetes_node_group_profile.masternodegrp
  ]
  action = "Deploy"
  name = intersight_kubernetes_cluster_profile.kubeprof.name
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.organization_moid.results.0.moid 
  }

}

#Wait for cluster to come up and then outpt the kubeconfig, if successful
output "kube_config" {
	value = intersight_kubernetes_cluster_profile.kubeprofaction.kube_config[0].kube_config
}


locals {
  organization= yamldecode(data.terraform_remote_state.global.outputs.organization)
  ippool_list = yamldecode(data.terraform_remote_state.global.outputs.ip_pool_policy)
  netcfg_list = yamldecode(data.terraform_remote_state.global.outputs.network_pod)
  syscfg_list = yamldecode(data.terraform_remote_state.global.outputs.network_service)
  clustername = yamldecode(data.terraform_remote_state.global.outputs.clustername)
  mgmtcfgetcd = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfgetcd)
  mgmtcfglbcnt = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfglbcnt)
  mgmtcfgsshuser = yamldecode(data.terraform_remote_state.global.outputs.mgmtcfgsshuser)
  ippoolmaster_list = yamldecode(data.terraform_remote_state.global.outputs.ip_pool_policy)
  ippoolworker_list = yamldecode(data.terraform_remote_state.global.outputs.ip_pool_policy)
  kubever_list = yamldecode(data.terraform_remote_state.global.outputs.k8s_version_name)
  infrapolname = yamldecode(data.terraform_remote_state.global.outputs.infrapolname)
  instancetypename = yamldecode(data.terraform_remote_state.global.outputs.instancetypename)
  mastergrpname = yamldecode(data.terraform_remote_state.global.outputs.mastergrpname)
  masterdesiredsize = yamldecode(data.terraform_remote_state.global.outputs.masterdesiredsize)
  masterinfraname = yamldecode(data.terraform_remote_state.global.outputs.masterinfraname)
}



