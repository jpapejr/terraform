output "public_ip" {
    value = ibm_is_floating_ip.floatingip1.address
}