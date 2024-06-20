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