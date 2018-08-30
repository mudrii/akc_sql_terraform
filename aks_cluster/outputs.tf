output "ekc_client_key" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_key}"
}

output "ekc_client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
}

output "ekc_cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate}"
}

output "ekc_cluster_username" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
}

output "ekc_cluster_password" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
}

output "ekc_kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "ekc_host" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}

output "ekc_subnet_id" {
  value = "${azurerm_kubernetes_cluster.k8s.agent_pool_profile.0.vnet_subnet_id}"
}

output "ekc_network_plugin" {
  value = "${azurerm_kubernetes_cluster.k8s.network_profile.0.network_plugin}"
}

output "ekc_service_cidr" {
  value = "${azurerm_kubernetes_cluster.k8s.network_profile.0.service_cidr}"
}

output "ekc_dns_service_ip" {
  value = "${azurerm_kubernetes_cluster.k8s.network_profile.0.dns_service_ip}"
}

output "ekc_docker_bridge_cidr" {
  value = "${azurerm_kubernetes_cluster.k8s.network_profile.0.docker_bridge_cidr}"
}

output "ekc_pod_cidr" {
  value = "${azurerm_kubernetes_cluster.k8s.network_profile.0.pod_cidr}"
}