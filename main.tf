resource "azurerm_log_analytics_workspace" "adl_law" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku

}

resource "azurerm_application_insights" "adl_appi" {
  name                = var.appi_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.adl_law.id

}

resource "azurerm_eventhub_namespace" "adl-t-itn-evhns" {
  name                = var.eventhub_namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = var.capacity
  zone_redundant      = true
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
  account_replication_type         = "ZRS"
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

resource "azurerm_storage_container" "auditlogs" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.adltitnexportlaw.name
  container_access_type = "private"
}

resource "azurerm_stream_analytics_job" "streamjob" {
  name                                     = "example-job"
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
      [adl-t-itn-evhlawexport-32] 
                
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

resource "azurerm_stream_analytics_stream_input_eventhub" "example" {
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
  storage_account_key       = azurerm_storage_account.adltitnexportlaw.primary_access_key
  path_pattern              = "audit-logs/{date}/{datetime:HH}/{datetime:mm}"
  date_format               = "yyyy-MM-dd"
  time_format               = "HH"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}
