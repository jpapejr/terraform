resource "ibm_is_instance" "instance1" {
  name       = "${var.project_name}-${var.environment}-mgr"
  image      = var.imageid
  profile    = var.profile

  primary_network_interface {
    subnet   = ibm_is_vpc.iac_iks_vpc.id
    security_groups = [ ibm_is_vpc.iac_iks_vpc.default_security_group ]
  }

  vpc            = ibm_is_vpc.iac_iks_vpc.id
  zone           = var.vpc_zone_names[0]
  resource_group = ibm_resource_group.group.id
  keys           = [data.ibm_is_ssh_key.sshkey.id]
  user_data      = file("${path.module}/bootstrap_v2.sh")
  depends_on     = [ ibm_resource_group.group, ibm_is_vpc.iac_iks_vpc, ibm_is_subnet.iac_subnet ]
}