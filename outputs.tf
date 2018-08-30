# resource group output 
output "res_group_id" {
  value       = "${module.res_group.res_group_id}"
  description = "Resource Group ID"
}

output "res_group_name" {
  value       = "${module.res_group.res_group_name}"
  description = "Resource Group Name"
}

# vpc output
output "vnet_id" {
  value = "${module.vpc.vnet_id}"
}

output "vnet_name" {
  value = "${module.vpc.vnet_name}"
}

output "vnet_location" {
  value = "${module.vpc.vnet_location}"
}

output "vnet_address_space" {
  value = "${module.vpc.vnet_address_space}"
}

# Network securety group
output "net_sec_group_id" {
  value = "${module.sec_group.net_sec_group_id}"
}

# subnet outputs
output "subnet_id" {
  value = "${module.subnet.subnet_id}"
}

output "subnet_address_prefix" {
  value = "${module.subnet.subnet_address_prefix}"
}

output "subnet_ip_configurations" {
  value = "${module.subnet.subnet_ip_configurations}"
}

# EKC outputs
output "ekc_client_key" {
  value       = "${module.eks_cluster.ekc_client_key}"
  description = "Client Key"
}

output "ekc_client_certificate" {
  value = "${module.eks_cluster.ekc_client_certificate}"
}

output "ekc_cluster_ca_certificate" {
  value = "${module.eks_cluster.ekc_cluster_ca_certificate}"
}

output "ekc_cluster_username" {
  value = "${module.eks_cluster.ekc_cluster_username}"
}

output "ekc_cluster_password" {
  value = "${module.eks_cluster.ekc_cluster_password}"
}

output "ekc_kube_config" {
  value = "${module.eks_cluster.ekc_kube_config}"
}

output "ekc_host" {
  value = "${module.eks_cluster.ekc_host}"
}

output "ekc_subnet_id" {
  value = "${module.eks_cluster.ekc_subnet_id}"
}

output "ekc_network_plugin" {
  value = "${module.eks_cluster.ekc_network_plugin}"
}

output "ekc_service_cidr" {
  value = "${module.eks_cluster.ekc_service_cidr}"
}

output "ekc_dns_service_ip" {
  value = "${module.eks_cluster.ekc_dns_service_ip}"
}

output "ekc_docker_bridge_cidr" {
  value = "${module.eks_cluster.ekc_docker_bridge_cidr}"
}

output "ekc_pod_cidr" {
  value = "${module.eks_cluster.ekc_pod_cidr}"
}

# Azure PostgreSQL
output "psql_id" {
  value = "${module.az_psql.psql_id}"
}

output "psql_fqdn" {
  value = "${module.az_psql.psql_fqdn}"
}
