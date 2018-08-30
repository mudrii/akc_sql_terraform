provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

module "res_group" {
  source   = "./resource_group"
  location = "${var.location}"
}

module "vpc" {
  source         = "./base/vpc"
  address_space  = "${var.address_space}"
  location       = "${var.location}"
  res_group_name = "${module.res_group.res_group_name}"
}

module "sec_group" {
  source         = "./base/sec_group"
  location       = "${var.location}"
  res_group_name = "${module.res_group.res_group_name}"
}

module "subnet" {
  source           = "./base/subnet"
  res_group_name   = "${module.res_group.res_group_name}"
  net_sec_group_id = "${module.sec_group.net_sec_group_id}"
  vnet_name        = "${module.vpc.vnet_name}"
  subnet_prefixes  = "${var.subnet_prefixes}"
}

module "eks_cluster" {
  source         = "./aks_cluster"
  res_group_name = "${module.res_group.res_group_name}"
  subnet_id      = "${module.subnet.subnet_id}"
  location       = "${var.location}"
  ssh_public_key = "${var.ssh_public_key}"
  agent_count    = "${var.agent_count}"
  client_id      = "${var.client_id}"
  client_secret  = "${var.client_secret}"
}

module "az_psql" {
  source                 = "./az_psql"
  location               = "${var.location}"
  res_group_name         = "${module.res_group.res_group_name}"
  pgsql_capacity         = "${var.pgsql_capacity}"
  pgsql_tier             = "${var.pgsql_tier}"
  pgsql_storage          = "${var.pgsql_storage}"
  pgsql_backup           = "${var.pgsql_backup}"
  pgsql_redundant_backup = "${var.pgsql_redundant_backup}"
  pgsql_password         = "${var.pgsql_password}"
}