variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group "
}

variable "application_insights" {
  type = object({
    id   = optional(string, ""),
    name = optional(string, ""),
  })
  validation {
    condition     = var.application_insights.id == "" && var.application_insights.name == ""
    error_message = "You must specify id or name"
  }
}

variable "log_analytics_workspace" {
  type = object({
    id            = optional(string, ""),
    name          = optional(string, ""),
    sku           = optional(string, "PerGB2018"),
    export_tables = list(string),
  })
  validation {
    condition     = var.log_analytics_workspace.id == "" && var.log_analytics_workspace.name == ""
    error_message = "You must specify id or name"
  }
}

variable "event_hub" {
  type = object({
    namespace_name           = string,
    capacity                 = number,
    auto_inflate_enabled     = bool,
    maximum_throughput_units = number,
  })
}

variable "storage_account" {
  type = object({
    name                               = string,
    account_replication_type           = optional(string, "ZRS"),
    access_tier                        = optional(string, "Hot"),
    immutability_policy_enabled        = bool,
    immutability_policy_retention_days = number,
  })
  validation {
    condition     = var.storage_account.account_replication_type != "ZRS" || var.storage_account.account_replication_type != "GZRS"
    error_message = "account_replication_type must be ZRS or GZRS"
  }
}

variable "stream_analytics_job" {
  type = object({
    name                 = string,
    streaming_units      = number,
    transformation_query = optional(string, "transformation_query.sql"),
  })
}

variable "data_explorer" {
  type = object({
    name         = string,
    sku_name     = string,
    sku_capacity = number,
  })
}

variable "tags" {
  type = map(any)
}
