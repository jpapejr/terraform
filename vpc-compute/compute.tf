resource "ibm_is_instance" "instance1" {
  name    = var.name
  image   = var.imageid
  profile = var.profile

  primary_network_interface {
    subnet = var.subnetid
    security_groups = [ var.sgid ]
  }

  vpc       = data.ibm_is_vpc.vpc.id
  zone      = var.zone
  keys      = [data.ibm_is_ssh_key.sshkey.id]
}