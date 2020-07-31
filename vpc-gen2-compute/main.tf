data "ibm_resource_group" "default_resource_group" {
  name = "default"
}

data "ibm_is_image" "image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

locals  {
  tags       =  ["compute-test"]
  az         = "us-east"
  root_name  = "compute-image"
  prefix1    = "10.241.0.0"
  prefix2    = "10.241.64.0"
  prefix3    = "10.241.128.0"
}


# AZ 1 address prefix
resource "ibm_is_vpc_address_prefix" "prefix1" {
  name = "${local.root_name}-addr-prefix1"
  zone   = "${local.az}-1"
  vpc         = ibm_is_vpc.vpc.id
  cidr        = "${local.prefix1}/18"
}

# AZ 2 address prefix
resource "ibm_is_vpc_address_prefix" "prefix2" {
  name = "${local.root_name}-addr-prefix2"
  zone   = "${local.az}-2"
  vpc         = ibm_is_vpc.vpc.id
  cidr        = "${local.prefix2}/18"
}

# AZ 3 address prefix
resource "ibm_is_vpc_address_prefix" "prefix3" {
  name = "${local.root_name}-addr-prefix3"
  zone   = "${local.az}-3"
  vpc         = ibm_is_vpc.vpc.id
  cidr        = "${local.prefix3}/18"
}

# Create VPC instance
resource "ibm_is_vpc" "vpc" {
    name                      = "${local.root_name}-vpc"
    resource_group            = data.ibm_resource_group.default_resource_group.id
    tags                      = local.tags
    address_prefix_management = "manual"
}

# Create a public gateway
resource "ibm_is_public_gateway" "gateway" {
    name             = "${local.root_name}-subnet1-pgw"
    vpc              = ibm_is_vpc.vpc.id
    zone             = "${local.az}-1"
    tags             = local.tags
}

# Create a subnet in first zone with a pgw
resource "ibm_is_subnet" "subnet1" {
    name                     = "${local.root_name}-subnet1"
    vpc                      = ibm_is_vpc.vpc.id
    zone                     = "${local.az}-1"
    ipv4_cidr_block          = "${local.prefix1}/24"
    public_gateway           = ibm_is_public_gateway.gateway.id
    resource_group           = data.ibm_resource_group.default_resource_group.id
}


resource "ibm_is_security_group_rule" "security_group_rule_tcp" {
    group = ibm_is_vpc.vpc.default_security_group
    direction = "inbound"
    tcp {
        port_min = 30000
        port_max = 32767
    }
 }

resource "ibm_is_security_group_rule" "security_group_rule_all" {
    group = ibm_is_vpc.vpc.default_security_group
    direction = "inbound"
    remote    = "0.0.0.0/0"
 }

 resource "ibm_is_security_group_rule" "security_group_rule_icmp" {
    group = ibm_is_vpc.vpc.default_security_group
    direction = "inbound"
    remote = "0.0.0.0/0"
    icmp {
        code = 20
        type = 30
    }
 }


#For accessing the cluster

# Create a new ssh key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
    name = local.root_name
    public_key = tls_private_key.key.public_key_openssh
    depends_on = [tls_private_key.key]
}


data "template_cloudinit_config" "app_userdata" {
  base64_encode = false
  gzip          = false

  part {
    content = <<EOF
#cloud-config
manage_etc_hosts: true
package_upgrade: false
packages:
- curl
- git
runcmd:
- 'curl -sL https://ibm.biz/idt-installer | bash' 
final_message: "The system is finally up, after $UPTIME seconds"
EOF

  }
}


resource "ibm_is_instance" "cluster_vsi" {
  name        = "jump-${local.root_name}"
  # this image is deprecated but the latest one fails to be recognized
  # https://ibm-argonauts.slack.com/archives/CLKR4FE90/p1596044075475200
  image       = data.ibm_is_image.image.id
  profile     = "bx2-2x8"

  primary_network_interface {
    subnet    = ibm_is_subnet.subnet1.id
  }

  vpc        = ibm_is_vpc.vpc.id
  zone       = "${local.az}-1"
  keys       = [ibm_is_ssh_key.ssh_key.id]
  tags       = local.tags
  user_data  = data.template_cloudinit_config.app_userdata.rendered
  depends_on = [ibm_is_ssh_key.ssh_key]
}

resource "ibm_is_floating_ip" "fip" {
  name   = "${local.root_name}-fip"
  target = ibm_is_instance.cluster_vsi.primary_network_interface.0.id
}