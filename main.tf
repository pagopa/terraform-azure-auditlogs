resource "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace.id == "" ? 1 : 0
  name                = var.log_analytics_workspace.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace.sku

  tags = var.tags
}

resource "azurerm_log_analytics_data_export_rule" "this" {
  for_each = var.log_analytics_workspace.export_tables

  name                    = each.value
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = var.log_analytics_workspace.id == "" ? azurerm_log_analytics_workspace.this[0].id : var.log_analytics_workspace.id
  destination_resource_id = azurerm_eventhub.this.id
  table_names             = each.value
  enabled                 = true
}

resource "azurerm_application_insights" "this" {
  count               = var.application_insights.name == "" ? 1 : 0
  name                = var.application_insights.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace.id == "" ? azurerm_log_analytics_workspace.this[0].id : var.log_analytics_workspace.id

  tags = var.tags
}

resource "azurerm_eventhub_namespace" "this" {
  name                     = var.event_hub.namespace_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  capacity                 = var.event_hub.capacity
  auto_inflate_enabled     = var.event_hub.auto_inflate_enabled
  maximum_throughput_units = var.event_hub.maximum_throughput_units
  zone_redundant           = true

  tags = var.tags
}

resource "azurerm_eventhub" "this" {
  name                = "audit-logs"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = 32
  message_retention   = 7
}

resource "azurerm_storage_account" "this" {
  name                             = var.storage_account.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_replication_type         = var.storage_account.account_replication_type
  account_tier                     = "Standard"
  access_tier                      = var.storage_account.access_tier
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false

  dynamic "immutability_policy" {
    for_each = var.storage_account.immutability_policy_enabled ? ["enabled"] : []
    content {
      allow_protected_append_writes = true
      period_since_creation_in_days = var.storage_account.immutability_policy_retention_days
      state                         = "Unlocked"
    }
  }

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_stream_analytics_job" "this" {
  name                                     = var.stream_analytics_job.name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-US"
  events_late_arrival_max_delay_in_seconds = 5
  events_out_of_order_max_delay_in_seconds = 5
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Stop"
  streaming_units                          = var.stream_analytics_job.streaming_units
  identity {
    type = "SystemAssigned"
  }

  transformation_query = file("${path.module}/${var.stream_analytics_job.transformation_query}")
}

resource "azurerm_eventhub_consumer_group" "evh-consumer" {
  name                = "evh-consumergroup"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_stream_analytics_stream_input_eventhub" "stream-input" {
  name                         = "eventhub-stream-input"
  stream_analytics_job_name    = azurerm_stream_analytics_job.this.name
  resource_group_name          = var.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.evh-consumer.name
  eventhub_name                = azurerm_eventhub.this.name
  servicebus_namespace         = azurerm_eventhub_namespace.this.name
  authentication_mode          = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_output_blob" "stream-output" {
  name                      = "this-container-output"
  stream_analytics_job_name = azurerm_stream_analytics_job.this.name
  resource_group_name       = var.resource_group_name
  storage_account_name      = azurerm_storage_account.this.name
  storage_container_name    = azurerm_storage_container.this.name
  path_pattern              = "audit-logs/{date}/{datetime:HH}/{datetime:mm}"
  date_format               = "yyyy-MM-dd"
  time_format               = "HH"
  authentication_mode       = "Msi"
  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}

resource "azurerm_stream_analytics_job_schedule" "job-schedule" {
  stream_analytics_job_id = azurerm_stream_analytics_job.this.id
  start_mode              = "LastOutputEventTime" # "JobStartTime" #use when last stopped

  depends_on = [
    azurerm_stream_analytics_stream_input_eventhub.stream-input,
    azurerm_stream_analytics_output_blob.stream-output,
  ]
}

resource "azurerm_role_assignment" "stream_analytics_azure_event_hubs_data_receiver" {
  scope                = azurerm_eventhub_namespace.this.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_stream_analytics_job.this.identity.0.principal_id
}

resource "azurerm_role_assignment" "stream_analytics_storage_blob_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_stream_analytics_job.this.identity.0.principal_id
}

resource "azurerm_kusto_cluster" "this" {
  name                = var.data_explorer.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.data_explorer.sku_name
    capacity = var.data_explorer.sku_capacity
  }

  zones = ["1", "2", "3"]

  tags = var.tags
}

resource "azurerm_kusto_database" "this" {
  name                = "audit-logs"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = azurerm_kusto_cluster.this.name

  hot_cache_period   = "P7D"
  soft_delete_period = "P30D"
}
