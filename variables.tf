variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group "
}

variable "log_analytics_workspace" {
  type = object({
    id            = string,
    export_tables = list(string),
  })
}

variable "event_hub" {
  type = object({
    namespace_name           = string,
    maximum_throughput_units = number,
  })
}

variable "storage_account" {
  type = object({
    name                               = string,
    account_replication_type           = optional(string, "ZRS"),
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
    tenant_id    = string,
    script_content = optional(string, "external_table.sql"),
    reader_groups = list(string),
    admin_groups  = list(string)
  })
}

variable "logic_app" {
  type = object({
    name                 = string,
    storage_account_name = string,
    plan_name            = string,
    plan_size            = optional(string, "WS1"),
  })
}

variable "tags" {
  type = map(any)
}
