resource azurerm_network_security_group "net_sec_group" {
  name                = "akc-${terraform.workspace}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"

  tags {
    environment = "${terraform.workspace}"
  }
}