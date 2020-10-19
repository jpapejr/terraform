#!/bin/bash
# Run from within a ibmterraform/terraform-provider-ibm-docker 
# container image:
#   docker run -it -v $(pwd):/tf ibmterraform/terraform-provider-ibm-docker
terraform init
terraform $@ \
  -var 'project_name=jtp' \
  -var 'environment=demo' \
  -var 'rg=jtp-demo' \
  -var "ibmcloud_api_key=$IBMCLOUD_APIKEY"
  -var 'profile=cx2-4x8'
  #-var 'instance_identifier=instX'
  #-var 'zone=us-east-1' \
  #-var 'imageid=r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00' \
  
  
 