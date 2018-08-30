variable "location" {
  description = "Azure location"
}

variable "res_group_name" {
  description = "Azure resource group name"
}

variable "ssh_public_key" {
  #	type = "map"
  description = "Azure ssh key_data"
}

variable "agent_count" {
  type        = "map"
  description = "Azure agent_count"
}

variable "client_id" {
  description = "Azure client_id"
}

variable "client_secret" {
  description = "Azure client_secret"
}

variable "subnet_id" {
  description = "Azure subnet ID"
}