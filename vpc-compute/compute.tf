resource "ibm_is_instance" "instance1" {
  name       = "${var.project_name}-${var.environment}-${var.instance_identifier}"
  image      = var.imageid
  profile    = var.profile

  primary_network_interface {
    subnet   = ibm_is_subnet.iac_subnet.id
    security_groups = [ ibm_is_vpc.iac_vpc.default_security_group ]
  }

  vpc            = ibm_is_vpc.iac_vpc.id
  zone           = var.zone
  resource_group = ibm_resource_group.group
  keys           = [data.ibm_is_ssh_key.sshkey.id]
  user_data      = file("${path.module}/bootstrap_v2.sh")
  depends_on     = [ ibm_resource_group.group, ibm_is_vpc.iac_vpc, ibm_is_subnet.iac_subnet ]
}