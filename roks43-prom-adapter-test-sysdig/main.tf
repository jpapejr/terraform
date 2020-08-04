data "ibm_resource_group" "default_resource_group" {
  name = "default"
}

locals  {
  tags       =  ["kp", "cmo", "prom-adapter", "sysdig"]
  az         = "syd01"
  root_name  = "kp-prom-sd" #best to keep this around 10-12 chars
}

# Create a public vlan
resource "ibm_network_vlan" "cluster_vlan_public" {
  name       = "${local.root_name}-ad-pb"
  datacenter = local.az
  type       = "PUBLIC"
  tags       = local.tags
}

# Create a private vlan
resource "ibm_network_vlan" "cluster_vlan_private" {
  name       = "${local.root_name}-ad-pr"
  datacenter = local.az
  type       = "PRIVATE"
  tags       = local.tags
}

resource "ibm_subnet" "portable_subnet" {
  type = "Portable"
  private = false
  ip_version = 4
  capacity = 16
  vlan_id = ibm_network_vlan.cluster_vlan_public.id
  notes = "${local.root_name}-adapter-test"
  //User can increase timeouts 
  timeouts {
    create = "45m"
  }
}


resource "ibm_container_cluster" "cluster" {
  name                     = local.root_name
  datacenter               = local.az
  no_subnet                = true
  subnet_id                = [ibm_subnet.portable_subnet.id]
  kube_version             = "4.3_openshift"
  default_pool_size        = 3
  hardware                 = "shared"
  resource_group_id        = data.ibm_resource_group.default_resource_group.id
  machine_type             = "b3c.8x32"
  public_vlan_id           = ibm_network_vlan.cluster_vlan_public.id
  private_vlan_id          = ibm_network_vlan.cluster_vlan_private.id
  public_service_endpoint  = true
  private_service_endpoint = true
  tags                     = local.tags
}

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = ibm_container_cluster.cluster.id
  admin           = true
}


#For accessing the cluster

# Create a new ssh key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_compute_ssh_key" "ssh_key" {
  label      = local.root_name
  notes      = local.root_name
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

resource "ibm_compute_vm_instance" "cluster_vsi" {
    hostname                   = "jump-${local.root_name}"
    domain                     = "cloud.ibm"
    os_reference_code          = "UBUNTU_LATEST_64"
    datacenter                 = local.az
    network_speed              = 100
    hourly_billing             = true
    private_network_only       = false
    cores                      = 2
    memory                     = 2048
    disks                      = [25, 10, 20]
    user_metadata              = data.template_cloudinit_config.app_userdata.rendered
    local_disk                 = false
    public_vlan_id             = ibm_network_vlan.cluster_vlan_public.id
    private_vlan_id            = ibm_network_vlan.cluster_vlan_private.id
    ssh_key_ids                = [ibm_compute_ssh_key.ssh_key.id]
    tags                       = local.tags
    depends_on = [ibm_compute_ssh_key.ssh_key]
}