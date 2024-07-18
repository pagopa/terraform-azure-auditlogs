resource "azurerm_log_analytics_data_export_rule" "this" {
  for_each = toset(var.log_analytics_workspace.export_tables)

  name                    = each.value
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = var.log_analytics_workspace.id
  destination_resource_id = azurerm_eventhub.law.id
  table_names             = [each.value]
  enabled                 = true
}

resource "azurerm_eventhub_namespace" "this" {
  name                     = var.event_hub.namespace_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  auto_inflate_enabled     = true
  maximum_throughput_units = var.event_hub.maximum_throughput_units
  zone_redundant           = true

  tags = var.tags

  lifecycle {
    ignore_changes = [
      capacity,
    ]
  }
}

resource "azurerm_eventhub" "law" {
  name                = "audit-logs-law"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = 32
  message_retention   = 7
}

resource "azurerm_eventhub" "filtered" {
  name                = "audit-logs-filtered"
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
  access_tier                      = "Hot"
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

locals {
  stream_analytics_job = {
    input_name  = "audit-logs-input"
    output_name = "audit-logs-output"
  }
}

resource "azurerm_stream_analytics_job" "this" {
  name                                     = var.stream_analytics_job.name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  sku_name                                 = "StandardV2"
  compatibility_level                      = "1.2"
  data_locale                              = "en-US"
  events_late_arrival_max_delay_in_seconds = 864000
  events_out_of_order_max_delay_in_seconds = 599 # from Azure UI max value is 3599, but terraform supports max 599
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Stop"
  streaming_units                          = var.stream_analytics_job.streaming_units
  identity {
    type = "SystemAssigned"
  }

  transformation_query = templatefile("${path.module}/${var.stream_analytics_job.transformation_query}", {
    input_name  = local.stream_analytics_job.input_name,
    output_name = local.stream_analytics_job.output_name,
    }
  )

  tags = var.tags
}

resource "azurerm_stream_analytics_function_javascript_udf" "this" {
  name                      = "filteredRecords"
  stream_analytics_job_name = azurerm_stream_analytics_job.this.name
  resource_group_name       = var.resource_group_name

  script = file("${path.module}/filteredRecords.js")

  input {
    type = "any"
  }

  output {
    type = "any"
  }
}

resource "azurerm_eventhub_consumer_group" "law" {
  name                = "audit-logs-law-consumer-group"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.law.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_stream_analytics_stream_input_eventhub" "this" {
  name                         = local.stream_analytics_job.input_name
  stream_analytics_job_name    = azurerm_stream_analytics_job.this.name
  resource_group_name          = var.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.law.name
  eventhub_name                = azurerm_eventhub.law.name
  servicebus_namespace         = azurerm_eventhub_namespace.this.name
  authentication_mode          = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_output_eventhub" "this" {
  name                      = local.stream_analytics_job.output_name
  stream_analytics_job_name = azurerm_stream_analytics_job.this.name
  resource_group_name       = var.resource_group_name
  eventhub_name             = azurerm_eventhub.filtered.name
  servicebus_namespace      = azurerm_eventhub_namespace.this.name
  authentication_mode       = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "Array"
  }
}

resource "azurerm_stream_analytics_job_schedule" "this" {
  stream_analytics_job_id = azurerm_stream_analytics_job.this.id
  start_mode              = "JobStartTime"

  depends_on = [
    azurerm_stream_analytics_stream_input_eventhub.this,
    azurerm_stream_analytics_output_eventhub.this,
    azurerm_stream_analytics_function_javascript_udf.this,
    azurerm_role_assignment.stream_analytics_azure_event_hubs_data_receiver,
    azurerm_role_assignment.stream_analytics_azure_event_hubs_data_sender,
  ]

  lifecycle {
    ignore_changes = [
      start_mode
    ]
  }
}

resource "azurerm_role_assignment" "stream_analytics_azure_event_hubs_data_receiver" {
  scope                = azurerm_eventhub.law.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_stream_analytics_job.this.identity.0.principal_id
}

resource "azurerm_role_assignment" "stream_analytics_azure_event_hubs_data_sender" {
  scope                = azurerm_eventhub.filtered.id
  role_definition_name = "Azure Event Hubs Data Sender"
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

  identity {
    type = "SystemAssigned"
  }

  zones = ["1", "2", "3"]

  tags = var.tags
}

resource "azurerm_role_assignment" "kusto_cluster_blob_reader" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_kusto_cluster.this.identity.0.principal_id
}

resource "azurerm_kusto_database" "this" {
  name                = "audit-logs"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = azurerm_kusto_cluster.this.name

  hot_cache_period   = "P7D"
  soft_delete_period = "P30D"
}

