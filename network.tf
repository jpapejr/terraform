resource "ibm_is_vpc" "iac_iks_vpc" {
  name = "${var.project_name}-${var.environment}-vpc"
  resource_group = ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  count                     = local.max_size
  name                      = "${var.project_name}-${var.environment}-range-${format("%02s", count.index)}"
  zone                      = var.vpc_zone_names[count.index]
  vpc                       = ibm_is_vpc.iac_iks_vpc.id
  cidr                      = "172.26.${format("%01s", count.index)}.0/24"
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix2" {
  name                      = "${var.project_name}-${var.environment}-range-99"
  zone                      = var.vpc_zone_names[0]
  vpc                       = ibm_is_vpc.iac_iks_vpc.id
  cidr                      = "10.10.${format("%01s", count.index)}.0/24"
}

resource "ibm_is_subnet" "iac_iks_subnet" {
  count                    = local.max_size
  name                     = "${var.project_name}-${var.environment}-subnet-${format("%02s", count.index)}"
  zone                     = var.vpc_zone_names[count.index]
  vpc                      = ibm_is_vpc.iac_iks_vpc.id
  ipv4_cidr_block          = "172.26.${format("%01s", count.index)}.0/26"
  public_gateway           = ibm_is_public_gateway.iac_iks_gateway[count.index].id
  
  # total_ipv4_address_count = 64
  resource_group           = ibm_resource_group.group.id
  
  depends_on  = [ibm_is_vpc_address_prefix.vpc_address_prefix, ibm_is_public_gateway.iac_iks_gateway]
}

resource "ibm_is_subnet" "iac_subnet" {
  name                     = "${var.project_name}-${var.environment}-subnet-99}"
  zone                     = var.vpc_zone_names[0]
  vpc                      = ibm_is_vpc.iac_iks_vpc.id
  ipv4_cidr_block          = "10.10.${format("%01s", count.index)}.0/26"
  
  # total_ipv4_address_count = 64
  resource_group           = ibm_resource_group.group.id
  
  depends_on  = [ibm_is_vpc_address_prefix.vpc_address_prefix2]
}

resource "ibm_is_public_gateway" "iac_iks_gateway" {
    name  = "${var.project_name}-${var.environment}-gateway-${format("%02s", count.index)}"
    vpc   = ibm_is_vpc.iac_iks_vpc.id
    zone  = var.vpc_zone_names[count.index]
    count = local.max_size

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
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

resource "ibm_is_floating_ip" "floatingip1" {
  name                      = "${var.project_name}-${var.environment}-fip"
  target                    = ibm_is_instance.instance1.primary_network_interface[0].id
  depends_on                = [ ibm_is_vpc.iac_iks_vpc, ibm_is_instance.instance1 ]
}