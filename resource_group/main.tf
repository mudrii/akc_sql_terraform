resource "azurerm_resource_group" "res_group" {
  name     = "aks-${terraform.workspace}"
  location = "${var.location}"

  tags {
    environment = "${terraform.workspace}"
  }
}