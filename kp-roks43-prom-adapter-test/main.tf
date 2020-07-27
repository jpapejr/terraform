data "ibm_resource_group" "default_resource_group" {
  name = "default"
}

variable "tags" {
  type    = list(string)
  default = ["kp", "cmo", "prom-adapter"]
}

# Create a public vlan
resource "ibm_network_vlan" "cluster_vlan_public" {
  name       = "kp-roks43-prom-ad-pb"
  datacenter = "wdc07"
  type       = "PUBLIC"
  tags       = var.tags
}

# Create a private vlan
resource "ibm_network_vlan" "cluster_vlan_private" {
  name       = "kp-roks43-prom-ad-pr"
  datacenter = "wdc07"
  type       = "PRIVATE"
  tags       = var.tags
}

resource "ibm_subnet" "portable_subnet" {
  type = "Portable"
  private = false
  ip_version = 4
  capacity = 16
  vlan_id = ibm_network_vlan.cluster_vlan_public.id
  notes = "kp-roks43-prom-adapter-test"
  //User can increase timeouts 
  timeouts {
    create = "45m"
  }
}


resource "ibm_container_cluster" "cluster" {
  name                     = "kp-roks43-prom-adapter-test"
  datacenter               = "wdc07"
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
  tags                     = var.tags
}

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = ibm_container_cluster.cluster.id
  admin           = true
}


# For doing kube-y things
# provider "kubernetes" {
#   load_config_file       = "false"
#   host                   = data.ibm_container_cluster_config.mycluster.host
#   client_certificate     = data.ibm_container_cluster_config.mycluster.admin_certificate
#   client_key             = data.ibm_container_cluster_config.mycluster.admin_key
#   cluster_ca_certificate = data.ibm_container_cluster_config.mycluster.ca_certificate
# }

#For accessing the cluster

# Create a new ssh key
resource "ibm_compute_ssh_key" "ssh_key" {
  label = "kp-roks43-prom-adapter-test"
  notes = "kp-roks43-prom-adapter-test"
  public_key = var.ssh_public_key
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
    hostname                   = "jump-kp-roks43-prom-adapter-test"
    domain                     = "cloud.ibm"
    os_reference_code          = "UBUNTU_LATEST_64"
    datacenter                 = "wdc07"
    network_speed              = 10
    hourly_billing             = true
    private_network_only       = false
    cores                      = 2
    memory                     = 2048
    disks                      = [25, 10, 20]
    user_metadata              = data.template_cloudinit_config.app_userdata.rendered
    dedicated_acct_host_only   = true
    local_disk                 = false
    public_vlan_id             = ibm_network_vlan.cluster_vlan_public.id
    private_vlan_id            = ibm_network_vlan.cluster_vlan_private.id
    ssh_key_ids                = [ibm_compute_ssh_key.ssh_key.id]
    tags                       = var.tags
}