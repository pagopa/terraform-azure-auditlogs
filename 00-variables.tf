variable "debug" {
  type    = bool
  default = false
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "subnet_private_endpoint_id" {
  type        = string
  description = "Private endpoint subnet id"
}

variable "log_analytics_workspace" {
  type = object({
    id            = string,
    export_tables = list(string),
  })
}

variable "event_hub" {
  type = object({
    namespace_name = string,
    sku_name       = optional(string, "Standard"),
  })
  validation {
    condition     = var.event_hub.sku_name != "Standard" || var.event_hub.sku_name != "Premium"
    error_message = "sku_name must be Standard or Premium"
  }
}

variable "storage_account" {
  type = object({
    name_temp                          = string,
    name_immutable                     = string,
    account_replication_type           = optional(string, "ZRS"),
    immutability_policy_enabled        = bool,
    immutability_policy_retention_days = number,
    immutability_policy_state          = string,
  })
  validation {
    condition     = var.storage_account.account_replication_type != "ZRS" || var.storage_account.account_replication_type != "GZRS"
    error_message = "account_replication_type must be ZRS or GZRS"
  }
}

variable "stream_analytics_job" {
  type = object({
    name                 = string,
    transformation_query = optional(string, "transformation_query.sql"),
  })
}

variable "data_explorer" {
  type = object({
    name           = string,
    sku_name       = string,
    sku_capacity   = number,
    script_content = optional(string, "external_table.sql"),
    reader_groups  = list(string),
    admin_groups   = list(string)
  })
}

variable "tags" {
  type = map(any)
}
