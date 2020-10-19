variable "project_name" {}
variable "environment" {}
variable "instance_identifier" {
  description = "A unique string token to reference this instance by in the VPC"
  default = "inst1"
}

variable "zone" {
  description = "VPC region/zone to create the instance"
  default = "us-east-1"
}

variable "rg" {
  description = "Resource group for the new instance/project"
  default = "default"
}

variable "imageid" {
  default = "r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  description = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "profile" {
  description = "Cluster management cx2-2x4, Remote development cx2-4x8"
  default = "cx2-2x4"
}