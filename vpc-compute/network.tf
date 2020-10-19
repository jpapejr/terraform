resource "ibm_is_vpc" "iac_vpc" {
  name                      = "${var.project_name}-${var.environment}-vpc"
  resource_group            = ibm_resource_group.group.id
  address_prefix_management = "manual"
  depends_on                = [ ibm_resource_group.group ]
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  name                      = "${var.project_name}-${var.environment}-range-00"
  zone                      = var.zone
  vpc                       = ibm_is_vpc.iac_vpc.id
  cidr                      = "10.240.0.0/24"
  depends_on                = [ ibm_is_vpc.iac_vpc ]
}

resource "ibm_is_security_group_rule" "iac_iks_security_group_rule_tcp_k8s" {
  group     = ibm_is_vpc.iac_vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_subnet" "iac_subnet" {
  name                      = "${var.project_name}-${var.environment}-subnet-00"
  zone                      = var.zone
  vpc                       = ibm_is_vpc.iac_vpc.id
  ipv4_cidr_block           = "10.240.0.0/26"
  
  # total_ipv4_address_count = 64
  resource_group            = ibm_resource_group.group.id
  
  depends_on                = [ibm_is_vpc_address_prefix.vpc_address_prefix]
}

resource "ibm_is_floating_ip" "floatingip1" {
  name                      = "${var.project_name}-${var.environment}-fip"
  target                    = ibm_is_instance.instance1.primary_network_interface[0].id
  depends_on                = [ ibm_is_vpc.iac_vpc ]
}

