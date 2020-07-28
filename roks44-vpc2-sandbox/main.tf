data "ibm_resource_group" "default_resource_group" {
  name = "default"
}

locals  {
  tags       =  ["sandbox"]
  az         = "us-south"
  root_name  = "roks44-sandbox"
  res_group  = "default"
}

# Create VPC instance
resource "ibm_is_vpc" "vpc" {
    name           = "${local.root_name}-vpc"
    resource_group = local.res_group
    tags           = local.tags
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
    total_ipv4_address_count = "16"
    public_gateway           = ibm_is_public_gateway.gateway.id
    resource_group           = local.res_group
}

resource "ibm_resource_instance" "cos" {
  name     = "${local.root_name}-cos"
  service  = "cloud-object-storage"
  plan     = "standard"
  location = "global"
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${local.root_name}-cluster" 
  vpc_id            = ibm_is_vpc.vpc.id
  kube_version      = "4.4_openshift"
  flavor            = "bx2.4x16"
  worker_count      = "3"
  cos_instance_crn  = ibm_resource_instance.cos.id
  resource_group_id = data.ibm_resource_group.default_resource_group.id
  tags              = local.tags
  zones {
    subnet_id = ibm_is_subnet.subnet1.id
    name      = "${local.az}-1"
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
  image       = "r014-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  profile     = "bx2-2x8"

  primary_network_interface {
    subnet    = ibm_is_subnet.subnet1.id
  }

  network_interfaces {
    name      = "eth1"
    subnet    = ibm_is_subnet.subnet1.id
  }

  vpc        = ibm_is_vpc.vpc.id
  zone       = "${local.az}-1"
  keys       = [ibm_is_ssh_key.ssh_key.id]
  tags       = local.tags
  user_data  = data.template_cloudinit_config.app_userdata.rendered
  depends_on = [ibm_is_ssh_key.ssh_key]
}