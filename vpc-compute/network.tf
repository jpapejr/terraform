data "ibm_is_vpc" "vpc" {
  name = var.vpc
}

resource "ibm_is_floating_ip" "floatingip1" {
  name   = "${var.name}-ip"
  target = ibm_is_instance.instance1.primary_network_interface[0].id
}

