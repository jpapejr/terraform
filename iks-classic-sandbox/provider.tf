variable "iaas_classic_username" {}
variable "iaas_classic_api_key" {}
variable "ibmcloud_api_key" {}
variable "github_token" {}
variable "github_organization" {}

provider "ibm" {
    iaas_classic_username = var.iaas_classic_username
    iaas_classic_api_key  = var.iaas_classic_api_key
    ibmcloud_api_key      = var.ibmcloud_api_key
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
}