output "psql_id" {
  value = "${azurerm_postgresql_server.az_psql.id}"
}

output "psql_fqdn" {
  value = "${azurerm_postgresql_server.az_psql.fqdn}"
}