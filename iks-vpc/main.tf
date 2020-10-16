# Not required for IBM Cloud Schematics but required
# for local Terraform runs
variable ibmcloud_api_key {}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  generation       = 2
  region           = var.region
}
