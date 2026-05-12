variable "name" {
  description = "User assigned identity name"
  type        = string
}

variable "location" {
  description = "User assigned identity location"
  type        = string
}

variable "resource_group_name" {
  description = "User assigned identity resource group name"
  type        = string
}

variable "role_assignments" {
  description = "Map of role assignments for the user assigned identity"
  type = map(object({
    role_definition_name = string
    scope                = string
  }))
  default = {}
}

variable "key_vault_id" {
  type = string
  description = "Key Vault id to store app registration's secret"
}
