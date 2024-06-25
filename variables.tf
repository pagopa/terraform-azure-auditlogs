variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "law_name" {
  type        = string
  description = "Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created."
}

// Resource Group
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group "
}

variable "law_sku" {
  type        = string
  description = "Specifies the SKU for the Log Analytics Workspace"
  default     = "PerGB2018"
}

variable "appi_name" {
  type        = string
  description = "Specifies the name for the Application Insight"
}

variable "capacity" {
  type        = number
  description = "Specifies the Throughput unit for the Event Hub"
}

variable "eventhub_name" {
  type        = string
  description = "Specifies the EventHub Name"
}

variable "storage_account_name" {
  type        = string
  description = "Specifies the storage account name"
}

variable "eventhub_namespace_name" {
  type        = string
  description = "Specifies the Eventhub namespace name"
}

variable "storage_container_name" {
  type        = string
  description = "Specifies the storage account container name"
}

variable "auto_inflate" {
  type        = bool
  description = "Specifies if the autoscale is enabled or not for the Event hub Namespace"
}

variable "account_replication" {
  type        = string
  description = "Specifies the replication for the Storage account"
}

variable "account_tier" {
  type        = string
  description = "Specifies the account tier for the Storage account"
}

variable "access_tier" {
  type        = string
  description = "Specifies the access tier for the Storage account"
}

variable "export_rule_name" {
  type        = string
  description = "Specifies the name for the export rule"
}

variable "table_names" {
  type        = list(any)
  description = "Specifies the Table to be exported"
}

variable "law_exists" {
  type        = bool
  description = "Specifies if the log analytics already exists"
  default     = false
}

variable "app_insight_exists" {
  type        = bool
  description = "Specifies if the Application Insight already exists"
  default     = false
}

variable "tags" {
  type = map(any)
}

variable "stream_job_name" {
  type = string
}