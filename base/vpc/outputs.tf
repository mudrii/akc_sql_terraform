output "vnet_id" {
  value = "${azurerm_virtual_network.vpc.id}"
}

output "vnet_name" {
  value = "${azurerm_virtual_network.vpc.name}"
}

output "vnet_location" {
  value = "${azurerm_virtual_network.vpc.location}"
}

output "vnet_address_space" {
  value = "${azurerm_virtual_network.vpc.address_space}"
}