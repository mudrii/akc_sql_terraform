output "res_group_id" {
  value       = "${azurerm_resource_group.res_group.id}"
  description = "Resource Group ID"
}

output "res_group_name" {
  value       = "${azurerm_resource_group.res_group.name}"
  description = "Resource Group Name"
}