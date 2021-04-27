# Configuring IKS cluster with Cisco Intersight Service for Terraform on vSphere Infrastructure 

## Use Case Statement
* Use Intersight Terraform Provider to provision a single node k8s cluster using Terraform Intersight Provider on vSphere Infrastructure.
* Use Helm Terraform Provider to deploy a sample "Hello IKS" Application
* Use Helm Terraform Provider to deploy IWO (Intersight Workload Optimizer) Collector to collect app and infrastructure insights
* Use TFCB (Terraform Cloud for Business) to walk through this use case.

![alt text](https://github.com/prathjan/images/blob/main/iksnew.png?raw=true)

### Pre-requisites
1. Sign up for a user account on Intersight.com. You will need Premier license as well as IWO license to complete this use case. Log in to intersight.com and generate API/Secret Keys.
2. Sign up for a TFCB (Terraform for Cloud Business) at https://app.terraform.io/. Log in and generate the User API Key.
3. You will need access to a vSphere infrastructure with backend compute and storage provided by a UCS fabric
4. You will log into your Intersight account and create the following targets. Please refer to Intersight docs for details on how to create Targets:

        Assist

        vSphere

        UCS Emulator

        TFC Cloud

        TFC Cloud Agent


5. You will set up the following workspaces in TFCB and link to the VCS repos specified. You will set the execution mode as noted below. Also, please use the workspace names provided since there are dependencies defined around it:

        sb_globalvar -> https://github.com/CiscoDevNet/tfglobalvar.git -> Execution mode as Remote

        sb_k8sprofile -> https://github.com/CiscoDevNet/tfk8spolicy.git -> Execution mode as Remote

        sb_iks -> https://github.com/CiscoDevNet/intersight-tfb-iks.git -> Execution mode as Remote

        sb_iksapp -> https://github.com/CiscoDevNet/intersight-tfb-iks-app -> Execution mode as Agent

        sb_iwocollector -> https://github.com/CiscoDevNet/tfiwoapp.git -> -> Execution mode as Agent


6. You will open the workspace "sb_globalvar" in TFCB add the following variables based on your vSphere cluster:

        device_name = Name of the Virtual Machine Provider you wish to add. i.e vCenter

        portgroup = Name of the portgroup(s) to be used in this provider	

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


7. You will open the workspace "sb_globalvar" in TFCB and queue a plan manually. This will populate the global variables that will be used by the other TFCB workspaces.

8. You will add the following variables to the workspace "sb_iks" and flag it as sensitive:

api_key = "Intersight API key"

secretkey = "Intersight secret key"

mgmtcfgsshkeys = "ssh key for cluster nodes"


9. You will add the following variables to the workspace "sb_k8sprofile" and flag it as sensitive:

api_key = "Intersight API key"

secretkey = "Intersight secret key"

password = "vsphere admin password"


10. You will add the following variables to the workspaces "sb_iksapp" and "sb_iwocollector"

ikswsname = sb_iks

### Provision a IKS Cluster with TFCB
Open "sb_iks" workspace and Queue a plan manually. Check for status of Run. If successful, it should look something like this:
![alt text](https://github.com/prathjan/images/blob/main/iksout.png?raw=true)

If successful, download the cluster kubeconfig from Intersight and run a couple of kubectl commands to verify an operational cluster:

kubectl get nodes

kubectl get pods --all-namespaces

### Deploy a sample "Hello IKS" App using Helm
Open "sb_iksapp" and Queue a plan manually. 
If successful, access the app with the loadbalancer IP:

kubectl get svc --all-namespaces

Open URL in a browser window.

### Deploy IWO collector using Helm
Open "sb_iwocollector" and Queue a plan manually.
If successful, open the Optimizer in Intersight and view insights for the App just deployed.
