#!/bin/bash
# Run from within a ibmterraform/terraform-provider-ibm-docker 
# container image:
#   docker run -it -v $(pwd):/tf ibmterraform/terraform-provider-ibm-docker
terraform init
terraform $1 \
  -var 'project_name=myproj' \
  -var 'environment=demo' \
  -var "ibmcloud_api_key=$IBMCLOUD_APIKEY"
  #-var 'resource_group=default' \
  #-var 'region=us-east' \
  #-var 'vpc_zone_names=["us-east-1"]' \
  #-var 'flavors=["mx2.4x32"]' \
  #-var 'workers_count=[2]' \
  #-var 'k8s_version=4.4_openshift' \
  #-var 'public_endpoint_disable=false'

