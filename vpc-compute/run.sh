#!/bin/bash
# Run from within a ibmterraform/terraform-provider-ibm-docker 
# container image:
#   docker run -it -v $(pwd):/tf ibmterraform/terraform-provider-ibm-docker
terraform init
terraform $@ \
  -var 'name=myinstance1' \
  -var "ibmcloud_api_key=$IBMCLOUD_APIKEY"
  #-var "zone=us-east-1" \
  #-var 'imageid=r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00' \
  #-var 'profile=cx2-2x4' \
  #-var 'vpc=jtp-1' \
  #-var 'subnetid=0757-7bec9127-c33c-4aa9-9110-c0bc3785e941' \
  #-var 'sgid=r014-aea61243-50a3-4a24-8f94-09656d193a07'
 