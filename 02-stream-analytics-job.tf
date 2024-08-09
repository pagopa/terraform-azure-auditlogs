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

resource "azurerm_stream_analytics_output_blob" "this" {
  name                      = local.stream_analytics_job.output_name
  stream_analytics_job_name = azurerm_stream_analytics_job.this.name
  resource_group_name       = var.resource_group_name
  storage_account_name      = azurerm_storage_account.temp.name
  storage_container_name    = azurerm_storage_container.temp.name
  path_pattern              = "${azurerm_storage_container.temp.name}/{date}/{time}/"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH/mm"
  authentication_mode       = "Msi"
  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}

resource "azurerm_stream_analytics_job_schedule" "this" {
  stream_analytics_job_id = azurerm_stream_analytics_job.this.id
  start_mode              = "JobStartTime"

  depends_on = [
    azurerm_stream_analytics_stream_input_eventhub.this,
    azurerm_stream_analytics_output_blob.this,
    azurerm_role_assignment.stream_analytics_azure_event_hubs_data_receiver,
    azurerm_role_assignment.stream_analytics_azure_storage_blob_data_contributor,
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

resource "azurerm_role_assignment" "stream_analytics_azure_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.temp.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_stream_analytics_job.this.identity.0.principal_id
}
