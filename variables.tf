variable "subscription_id" {
  description = "Azure subscription_id"
}

variable "client_id" {
  description = "Azure client_id"
}

variable "client_secret" {
  description = "Azure password"
}

variable "tenant_id" {
  description = "Azure tenant_id"
}

variable "location" {
  default     = "southeastasia"
  description = "Azure location"
}

variable "address_space" {
  description = "CIDR for the whole VPC"

  default = {
    prod = "10.10.0.0/16"
    dev  = "10.20.0.0/16"
  }
}

variable "subnet_prefixes" {
  description = "CIDR for the subnet"

  default = {
    prod = "10.10.0.0/24"
    dev  = "10.20.0.0/24"
  }
}

variable "agent_count" {
  description = "Nr of nodes"

  default = {
    prod = "4"
    dev  = "2"
  }
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "pgsql_capacity" {
  description = "The scale up/out capacity, representing server's compute units."

  default = {
    prod = "30"
    dev  = "2"
  }
}

variable "pgsql_tier" {
  description = "Possible values are Basic, GeneralPurpose, and MemoryOptimized."

  default = {
    prod = "GeneralPurpose"
    dev  = "Basic"
  }
}

variable "pgsql_storage" {
  description = "Max storage allowed for a server Possible values are between 5120 MB(5GB) and 1048576 MB(1TB)"

  default = {
    prod = "10240"
    dev  = "5120"
  }
}

variable "pgsql_backup" {
  description = "Backup retention days for the server, supported values are between 7 and 35 days."

  default = {
    prod = "35"
    dev  = "7"
  }
}

variable "pgsql_redundant_backup" {
  description = "Enable Geo-redundant or not for server backup"

  default = {
    prod = "Enabled"
    dev  = "Disabled"
  }
}

variable "pgsql_password" {
  description = "DB password"
}