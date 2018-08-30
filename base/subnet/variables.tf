variable "res_group_name" {
  description = "Azure resource group name"
}

variable "net_sec_group_id" {
  description = "Network securety group ID"
}

variable "vnet_name" {
  description = "VPC Name"
}

variable "subnet_prefixes" {
  type        = "map"
  description = "Subnet CIDR"
}