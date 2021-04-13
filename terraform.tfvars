# 
# Example .tfvars file
# Can be copied to terraform.tfvars and edited so that Terraform will automatically use variables from this file.
#
api_key_id = "604bb4c77564612d334281b8/604bb4c77564612d334281bd/606f7b537564612d339b9712"
api_private_key = "/Users/prathjan/Downloads/Secret104.txt"
mgmtcfgsshkeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkPIkcSWkLxdEeMCTr3eMB7L20GEQpIfKDlvoPHGe6f prathjan@PRATHJAN-M-T39V"





name = "testsandbox3"


# profile params
# IP Pool name and moid 
ippool_list = "testpool"

# Netcfg name
netcfg_list = "netcfg"
# Syscfg name
syscfg_list = "syscfg"
infra_list = "TestsbInfra"
ippoolmaster_list = "testpool"
ippoolworker_list = "testpool"
kubever_list = "k8sversion"
orgobjtype = "organization.Organization"
mgmtcfgetcd = false
mgmtcfglbcnt = 1
mgmtcfgsshuser = "iksadmin"
mastergrpname = "test3-master-pool"
masterdesiredsize = 1
workergrpname = "test3-worker-pool"
workerdesiredsize = 0
masterinfraname = "masterinfraname3"
infrapolname = "TestsbInfra"
instancetypename = "testMcType"



