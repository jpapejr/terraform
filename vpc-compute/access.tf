resource "ibm_resource_group" "group" {
  name                  = "${var.project_name}-${var.environment}"
}