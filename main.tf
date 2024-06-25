resource "azurerm_log_analytics_workspace" "adl_law" {
  count               = var.law_exists ? 0 : 1
  name                = var.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  tags                = var.tags
}

resource "azurerm_application_insights" "adl_appi" {
  count               = var.app_insight_exists ? 0 : 1
  name                = var.appi_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.adl_law[0].id
  tags                = var.tags
}

resource "azurerm_eventhub_namespace" "adl-t-itn-evhns" {
  name                     = var.eventhub_namespace_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  capacity                 = var.capacity
  auto_inflate_enabled     = var.auto_inflate
  maximum_throughput_units = 10
  zone_redundant           = true
  tags                     = var.tags
}

resource "azurerm_eventhub" "adl-t-itn-evh" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.adl-t-itn-evhns.name
  resource_group_name = var.resource_group_name
  partition_count     = 32
  message_retention   = 7
}

resource "azurerm_storage_account" "adltitnexportlaw" {
  name                             = var.storage_account_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_replication_type         = var.account_replication
  account_tier                     = var.account_tier
  access_tier                      = var.access_tier
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false


  /*immutability_policy {
    allow_protected_append_writes = true
    period_since_creation_in_days = 3650
    state = "Unlocked"
  }
*/
  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "auditlogs" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.adltitnexportlaw.name
  container_access_type = "private"
}

resource "azurerm_stream_analytics_job" "streamjob" {
  name                                     = var.stream_job_name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-US"
  events_late_arrival_max_delay_in_seconds = 5
  events_out_of_order_max_delay_in_seconds = 5
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Stop"
  streaming_units                          = 1
  identity {
    type = "SystemAssigned"
  }

  transformation_query = <<-EOT
  WITH records AS(
  SELECT
    records.arrayvalue as sig
    FROM
      [eventhub-stream-input] 
                
      CROSS APPLY GetArrayElements(records) AS records
               
  )
            
      SELECT
      sig.*
      INTO
      [adltitnexportlaw-container-output]
            
      FROM records
      where sig.Properties.audit='true'
          
        EOT
}
resource "azurerm_eventhub_consumer_group" "evh-consumer" {
  name                = "evh-consumergroup"
  namespace_name      = azurerm_eventhub_namespace.adl-t-itn-evhns.name
  eventhub_name       = azurerm_eventhub.adl-t-itn-evh.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_stream_analytics_stream_input_eventhub" "stream-input" {
  name                         = "eventhub-stream-input"
  stream_analytics_job_name    = azurerm_stream_analytics_job.streamjob.name
  resource_group_name          = var.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.evh-consumer.name
  eventhub_name                = azurerm_eventhub.adl-t-itn-evh.name
  servicebus_namespace         = azurerm_eventhub_namespace.adl-t-itn-evhns.name
  authentication_mode          = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_output_blob" "stream-output" {
  name                      = "adltitnexportlaw-container-output"
  stream_analytics_job_name = azurerm_stream_analytics_job.streamjob.name
  resource_group_name       = var.resource_group_name
  storage_account_name      = azurerm_storage_account.adltitnexportlaw.name
  storage_container_name    = azurerm_storage_container.auditlogs.name
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
  stream_analytics_job_id = azurerm_stream_analytics_job.streamjob.id
  start_mode              = "JobStartTime"

  depends_on = [

    azurerm_stream_analytics_stream_input_eventhub.stream-input,
    azurerm_stream_analytics_output_blob.stream-output,
  ]
}

resource "azurerm_log_analytics_data_export_rule" "example" {
  name                    = var.export_rule_name
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = azurerm_log_analytics_workspace.adl_law[0].id
  destination_resource_id = azurerm_eventhub.adl-t-itn-evh.id
  table_names             = var.table_names
  enabled                 = true
}

resource "azurerm_role_assignment" "role-evh" {
  scope                = azurerm_eventhub_namespace.adl-t-itn-evhns.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_stream_analytics_job.streamjob.identity.0.principal_id
}

resource "azurerm_role_assignment" "role-stg" {
  scope                = azurerm_storage_account.adltitnexportlaw.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_stream_analytics_job.streamjob.identity.0.principal_id
}

