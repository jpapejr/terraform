data "ibm_resource_group" "default_resource_group" {
  name = "default"
}

# Create a public vlan
resource "ibm_network_vlan" "cluster_vlan_public" {
  name       = "kp-roks43-prom-ad-pb"
  datacenter = "wdc07"
  type       = "PUBLIC"
  tags       = ["kp", "cmo", "prom-adapter"]
}

# Create a private vlan
resource "ibm_network_vlan" "cluster_vlan_private" {
  name       = "kp-roks43-prom-ad-pr"
  datacenter = "wdc07"
  type       = "PRIVATE"
  tags       = ["kp", "cmo", "prom-adapter"]
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
  tags                     = ["kp", "cmo", "prom-adapter"]
}

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = ibm_container_cluster.cluster.id
  admin           = true
}


# provider "kubernetes" {
#   load_config_file       = "false"
#   host                   = data.ibm_container_cluster_config.mycluster.host
#   client_certificate     = data.ibm_container_cluster_config.mycluster.admin_certificate
#   client_key             = data.ibm_container_cluster_config.mycluster.admin_key
#   cluster_ca_certificate = data.ibm_container_cluster_config.mycluster.ca_certificate
# }