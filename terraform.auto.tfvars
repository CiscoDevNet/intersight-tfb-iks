# 
# Example .tfvars file
# Can be copied to terraform.tfvars and edited so that Terraform will automatically use variables from this file.
#

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
mgmtcfglbcnt = 3
mgmtcfgsshuser = "iksadmin"
mastergrpname = "test3-master-pool"
masterdesiredsize = 1
workergrpname = "test3-worker-pool"
workerdesiredsize = 0
masterinfraname = "masterinfraname3"
infrapolname = "TestsbInfra"
instancetypename = "testMcType"



