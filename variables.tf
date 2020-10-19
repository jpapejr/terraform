variable "project_name" {}
variable "environment" {}


variable "region" {
  default = "us-east"
}
variable "vpc_zone_names" {
  type    = list
  default = ["us-east-1"]
}
variable "flavors" {
  type    = list
  default = ["mx2.4x32"]
}
variable "workers_count" {
  type    = list
  default = [2]
}
variable "k8s_version" {
  default = "4.4_openshift"
}

variable "public_endpoint_disable" {
  type = bool
  default = false
}

variable "imageid" {
  default = "r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  description = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "profile" {
  description = "Cluster management cx2-2x4, Remote development cx2-4x8"
  default = "cx2-2x4"
}

locals {
  max_size = length(var.vpc_zone_names)
}
