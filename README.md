# Configuring IKS cluster with Cisco Intersight Service for Terraform on vSphere Infrastructure 
## Contents
        Use Cases
        Pre-requisites, Guidelines
        Provision IKS Policies and IP Pools with TFCB
        Provision a IKS Cluster with TFCB
        Deploy a sample "Hello IKS" App using Helm
        Deploy IWO collector using Helm
        Try with a Sandbox


### Use Cases
* As a Cloud Admin, use IST (Intersight Service for Terraform) to provision IKS Policies to be leveraged by DevOps in their IKS cluster provisioning
* As DevOps, use IST ((Intersight Service for Terraform) and IKS policies provided by Cloud Admin to provision a single node k8s cluster on vSphere Infrastructure.
* As app Developer, use IST to deploy a sample "Hello IKS" Application
* As app Developer, use IST to deploy IWO (Intersight Workload Optimizer) Collector to collect app and infrastructure insights

![alt text](https://github.com/prathjan/images/blob/main/iksnew.png?raw=true)

### Pre-requisites, Guidelines
1. Sign up for a user account on Intersight.com. You will need Premier license as well as IWO license to complete this use case. Log in to intersight.com and generate API/Secret Keys.

2. Sign up for a TFCB (Terraform for Cloud Business) at https://app.terraform.io/. Log in and generate the User API Key. You will need this when you create the TF Cloud Target in Intersight.

3. You will need access to a vSphere infrastructure with backend compute and storage provisioned

4. You will log into your Intersight account and create the following targets. Please refer to Intersight docs for details on how to create these Targets:

    Assist
    vSphere
    UCS Emulator
    TFC Cloud
    TFC Cloud Agent - When you claim the TF Cloud Agent, please make sure you have the following added to your Managed Hosts. This is in addition to other local subnets you may have that hosts your kubernetes cluster like the IPPool that you may configure for your k8s addressing:
    NO_PROXY URL's listed:

            github-releases.githubusercontent.com
            github.com
            app.terraform.io
            registry.terraform.io
            releases.hashicorp.com
            archivist.terraform.io
            prathjan.github.io


5. If you are leveraging CiscoDevNet organization in app.terraform,io, please go to Step 7. Else go to Step 6.

6. If you have your own TFCB organization and would like to use that, you will have to change the terraform configuration to account for this. Please clone the following repos and create your own corresponding GIT repos. Look for CiscoDeNet org references in the TF files and replace with your own organization:

Clone following repos:

https://github.com/CiscoDevNet/tfglobalvar.git

https://github.com/CiscoDevNet/tfk8spolicy.git

https://github.com/CiscoDevNet/intersight-tfb-iks.git

https://github.com/CiscoDevNet/tfiksapp.git 

https://github.com/CiscoDevNet/tfiwoapp.git

https://github.com/CiscoDevNet/tfiksdelete.git 


With CiscoDevNet TFCB org:

data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = "CiscoDevNet"
    workspaces = {
      name = var.globalwsname
    }
  }
}

With your own TFCB org:

data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = "Lab14"
    workspaces = {
      name = var.globalwsname
    }
  }
}

You will set up the following workspaces in TFCB and link to you VCS repos. You will set the execution mode as noted below. Also, please use the workspace names provided since there are dependencies defined around it:

    sb_globalvar -> <your_repo_tfglobalvar.git> -> Execution mode as Remote

    sb_k8sprofile -> <your_repo_tfk8spolicy.git> -> Execution mode as Remote

    sb_iks -> <your_repo_intersight-tfb-iks.git> -> Execution mode as Remote

    sb_iksapp -> <your_repo_tfiksapp.git> -> Execution mode as Agent

    sb_iwocollector -> <your_repo_tfiwoapp.git> -> Execution mode as Agent

    sb_iksdelete -> <your_repo_tfiksdelete.git> -> Execute mode as Remote


7. You will set up the following workspaces in TFCB and link to the VCS repos specified. You will set the execution mode as noted below. Also, please use the workspace names provided since there are dependencies defined around it:

    sb_globalvar -> https://github.com/CiscoDevNet/tfglobalvar.git -> Execution mode as Remote

    sb_k8sprofile -> https://github.com/CiscoDevNet/tfk8spolicy.git -> Execution mode as Remote

    sb_iks -> https://github.com/CiscoDevNet/intersight-tfb-iks.git -> Execution mode as Remote

    sb_iksapp -> https://github.com/CiscoDevNet/tfiksapp.git -> Execution mode as Agent

    sb_iwocollector -> https://github.com/CiscoDevNet/tfiwoapp.git -> Execution mode as Agent

    sb_iksdelete -> https://github.com/CiscoDevNet/tfiksdelete.git -> Execute mode as Remote


6. You will open the workspace "sb_globalvar" in TFCB add the following variables based on your vSphere cluster:

    device_name = Name of the Virtual Machine Provider you wish to add. i.e vCenter

    portgroup = Name of the portgroup(s) to be used in this provider. Example: "Management"

    datastore = Name of the datastore to be used with this provider.

    vspherecluster = Name of the cluster you wish to make part of this provider within vCenter.

    resource_pool = Name of the resource pool to be used with this provider.	

    organization = Intersight Organization name

    #ip_pool_policy params

    starting_address = Starting IP Address you want for this pool.

    pool_size = Number of IPs you want this pool to contain.

    netmask = Subnet Mask for this pool.

    gateway = Default gateway for this pool.

    primary_dns = Primary DNS Server for this pool.

    #instance type

    cpu = Number of CPU allocated to the virtual machine.

    disk_size = Amount of disk to be assigned to the virtual machine in GiB

    memory = Amount of memory assigned to the virtual machine in MiB.

    password = vSphere admin password -> mark as sensitive


    Please also set this workspace to share its data with other workspaces in the organization by enabling Settings->General Settings->Share State Globally.

7. You will open the workspace "sb_k8sprofile" and add the following variables:

    api_key = API key from Intersight for user

    secretkey = Secret key from Intersight for user -> mark as sensitive

    globalwsname = sb_globalvar

8. You will open the workspace "sb_iks" and add the following variables:

    api_key = API key from Intersight for user

    secretkey = Secret key from Intersight for user -> mark as sensitive

    mgmtcfgsshkeys = SSH public key -> mark as sensitive

    Please also set this workspace to share its data with other workspaces in the organization by enabling Settings->General Settings->Share State Globally.

9. You will open the workspace "sb_iksdelete" and add the following variables:

    api_key = API key from Intersight for user

    secretkey = Secret key from Intersight for user -> mark as sensitive

    globalwsname = sb_globalvar

10. You will open the workspace "sb_iksapp" and add the followin variable:

    ikswsname = sb_iks

    Please also make sure you have configured this workspace to use the Terraform cloud agent configured in your Intersight Target.

11. You will open the workspace "sb_globalvar" in TFCB and queue a plan manually. This will populate the global variables that will be used by the other TFCB workspaces.

12. You will execute the Runs in the workspaces in this order: 

    sb_k8sprofile - See section below on "Provision IKS Policies and IP Pools with TFCB"

    sb_iks - See section below on "Provision a IKS Cluster with TFCB"

    sb_iksapp - See section below on "Deploy a sample "Hello IKS" App using Helm"

    sb_iwocollector - See section below on "Deploy IWO collector using Helm"

### Provision IKS Policies and IP Pools with TFCB

Before IKS clusters can be created, policies and IP Pools need to be setup. The workspace "sb_k8sprofile" accounts for this.
Open "sb_k8sprofile" workspace and Queue a plan manually. Check for status of Run. If successful, it should look something like this:
![alt text](https://github.com/prathjan/images/blob/main/prof.png?raw=true)

### Provision a IKS Cluster with TFCB

Once policies are configured successfully, IKS clusters can be provisioned. The workspace "sb_iks" accounts for this.
Open "sb_iks" workspace and Queue a plan manually. Check for status of Run. If successful, it should look something like this:
![alt text](https://github.com/prathjan/images/blob/main/iksout.png?raw=true)

If successful, download the cluster kubeconfig from Intersight and run a couple of kubectl commands to verify an operational cluster:

kubectl get nodes

kubectl get pods --all-namespaces

### Deploy a sample "Hello IKS" App using Helm

What use is a cluster without an App deployment,rt? The workspace "sb_iksapp" accounts for this.
Open "sb_iksapp" and Queue a plan manually. 
If successful, access the app with the loadbalancer IP:

kubectl get svc --all-namespaces

Open URL in a browser window : https://<LB_IP>/

You should see this:

![alt text](https://github.com/prathjan/images/blob/main/helloiks.png?raw=true)

### Deploy IWO collector using Helm

Can't have that App runing without insights,correct? The workspace "sb_iwocollector" accounts for this.
Open "sb_iwocollector" and Queue a plan manually.

Once successful, the collector is installed in your k8s cluster and requires you to claim it as target in Intersight->Target. You will use the following steps to get the Device ID and Code:

    Download kubeconfig for the sbcluster from Intersight

    Execute: kubectl <path_to_kubeconfig> port-forward <collector_pod_id> 9110

    Execute this to get the Device ID: curl -s http://localhost:9110/DeviceIdentifiers

    Execte this to get the Claim Code: curl -s http://localhost:9110/SecurityTokens

If successful, open the Optimizer in Intersight and view insights for the App just deployed:

![alt text](https://github.com/prathjan/images/blob/main/insights.png?raw=true)

### De-provisioning

You can decommision all resources provisioned by queing a destroy plan in each workspace. Please use the workspace sb_iksdelete to delete the cluster. You can delete the policies after the cluster has been deleted.

### Try with a Sandbox

A sandbox covering a lot of the above concepts can be found here:

https://devnetsandbox.cisco.com/RM/Diagram/Index/daad55dd-45f1-46c6-a1b4-7339b318c970?diagramType=Topology