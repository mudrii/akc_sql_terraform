resource "azurerm_subnet" "subnet" {
  name                      = "akc-${terraform.workspace}-subnet"
  resource_group_name       = "${var.res_group_name}"
  network_security_group_id = "${var.net_sec_group_id}"
  virtual_network_name      = "${var.vnet_name}"
  address_prefix            = "${var.subnet_prefixes[terraform.workspace]}"
}