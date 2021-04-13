# Intersight Provider Information 
terraform {
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      version = "1.0.5"
    }
  }
}

provider "intersight" {
  apikey        = var.api_key_id
  secretkey = var.api_private_key
  endpoint      = var.api_endpoint
}

data "intersight_organization_organization" "organization_moid" {
  name = var.organization_name
}

output "organization_moid" {
  value = data.intersight_organization_organization.organization_moid.results.0.moid
}


# IPPool moids
data "intersight_ippool_pool" "ippool_moid" {
  name  = var.ippool_list
}

# Netcfg moids
data "intersight_kubernetes_network_policy" "netcfg_moid" {
  name  = var.netcfg_list
}

# Sysconfig moids
data "intersight_kubernetes_sys_config_policy" "syscfg_moid" {
  name  = var.syscfg_list
}


# kube cluster profiles
resource "intersight_kubernetes_cluster_profile" "kubeprof" {
  name = var.name 
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
	encrypted_etcd = var.mgmtcfgetcd
	load_balancer_count = var.mgmtcfglbcnt
	ssh_keys = [ 
		 var.mgmtcfgsshkeys
	]
	ssh_user = var.mgmtcfgsshuser
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
  name  = var.ippoolmaster_list
}

# IpPool moids
data "intersight_ippool_pool" "ippoolworker_moid" {
  name  = var.ippoolworker_list
}

# Kube version moids
data "intersight_kubernetes_version_policy" "kubever_moid" {
  name  = var.kubever_list
}

# Infra Config Policy
data "intersight_kubernetes_virtual_machine_infra_config_policy" "infrapol" {
  name  = var.infrapolname
}

# Instance Type
data "intersight_kubernetes_virtual_machine_instance_type" "instancetype" {
  name  = var.instancetypename
}

# Master
resource "intersight_kubernetes_node_group_profile" "masternodegrp" {
  name = var.mastergrpname
  node_type = "ControlPlane"
  desiredsize = var.masterdesiredsize

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
	name = var.masterinfraname
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
