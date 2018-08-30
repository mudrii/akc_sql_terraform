output "net_sec_group_id" {
  value       = "${azurerm_network_security_group.net_sec_group.id}"
  description = "Network securety group ID"
}