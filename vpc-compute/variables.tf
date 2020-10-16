variable "zone" {
  description = "VPC region to create the instance"
  default = "us-east-1"
}

variable "imageid" {
  default = "r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  description = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "profile" {
  description = "Cluster management cx2-2x4, Remote development cx2-4x8"
  default = "cx2-2x4"
}

variable "vpc" {
  description = "VPC to create the instance in"
  default = "jtp-1"
}

variable "name" {
  description = "Name of the instance"
}

variable "subnetid" {
  description = "ID of the VPC subnet to create the instance."
}

variable "sgid" {
  description = "ID of the security group to attach the instance to"  
}