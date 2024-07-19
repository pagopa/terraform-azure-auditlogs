resource "azurerm_storage_account" "logic_app" {
  name                             = replace("${var.logic_app.storage_account_name}", "-", "")
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "ZRS"
  access_tier                      = "Hot"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  tags                             = var.tags
}

resource "azurerm_service_plan" "logic_app" {
  name                = var.logic_app.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.logic_app.plan_size
  os_type  = "Windows"

  tags = var.tags
}

resource "azurerm_logic_app_standard" "logic_app" {
  name                       = var.logic_app.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_service_plan.logic_app.id
  storage_account_name       = azurerm_storage_account.logic_app.name
  storage_account_access_key = azurerm_storage_account.logic_app.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                   = "node"
    WEBSITE_NODE_DEFAULT_VERSION               = "~20"
    WORKFLOWS_SUBSCRIPTION_ID                  = data.azurerm_subscription.current.subscription_id
    WORKFLOWS_LOCATION                         = var.location
    WORKFLOWS_RESOURCE_GROUP_NAME              = var.resource_group_name
    WORKFLOWS_EVENTHUBS_CONNECTION_RUNTIME_URL = ""
    WORKFLOWS_AZUREBLOB_CONNECTION_RUNTIME_URL = ""
  }

  https_only = true
  version    = "~4"
  site_config {
    use_32_bit_worker_process = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_eventhub_consumer_group" "logic_app_filtered" {
  name                = "audit-logs-filtered-logic-app-consumer-group"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.filtered.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "logic_app_event_hubs_data_receiver" {
  scope                = azurerm_eventhub.filtered.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_logic_app_standard.logic_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "logic_app_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_logic_app_standard.logic_app.identity.0.principal_id
}

resource "azurerm_resource_group_template_deployment" "logic_app_eventub_connection" {
  name                = "eventhubs"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  deployment_mode     = "Incremental" # DO NOT CHANGE OTHERWISE YOU CAN ACCIDENTLY DELETE AZ RESOURCES
  template_content = templatefile("${path.module}/connection-eventhub.json", {
    name                = "eventhubs",
    resource_group_name = var.resource_group_name,
    subscription_id     = data.azurerm_subscription.current.subscription_id
    location            = var.location,
    eventhub_fqdn       = "${azurerm_eventhub_namespace.this.name}.servicebus.windows.net"
    }
  )
}

resource "azurerm_resource_group_template_deployment" "logic_app_eventub_connection_access_policy" {
  depends_on = [azurerm_resource_group_template_deployment.logic_app_eventub_connection]

  name                = "eventhubs-access-policy"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  deployment_mode     = "Incremental" # DO NOT CHANGE OTHERWISE YOU CAN ACCIDENTLY DELETE AZ RESOURCES
  template_content = templatefile("${path.module}/connection-eventhub-access-policy.json", {
    name      = "eventhubs/${azurerm_logic_app_standard.logic_app.name}-${azurerm_logic_app_standard.logic_app.identity.0.principal_id}",
    tenant_id = data.azurerm_subscription.current.tenant_id,
    object_id = azurerm_logic_app_standard.logic_app.identity.0.principal_id,
    location  = var.location,
    }
  )
}

resource "azurerm_resource_group_template_deployment" "logic_app_blob_connection" {
  name                = "azureblob"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  deployment_mode     = "Incremental" # DO NOT CHANGE OTHERWISE YOU CAN ACCIDENTLY DELETE AZ RESOURCES
  template_content = templatefile("${path.module}/connection-blob.json", {
    name                = "azureblob",
    resource_group_name = var.resource_group_name,
    subscription_id     = data.azurerm_subscription.current.subscription_id
    location            = var.location
    }
  )
}

output "test" {
  value = azurerm_resource_group_template_deployment.logic_app_blob_connection.output_content
}

resource "azurerm_resource_group_template_deployment" "logic_app_blob_connection_access_policy" {
  depends_on = [azurerm_resource_group_template_deployment.logic_app_blob_connection]

  name                = "azureblob-access-policy"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  deployment_mode     = "Incremental" # DO NOT CHANGE OTHERWISE YOU CAN ACCIDENTLY DELETE AZ RESOURCES
  template_content = templatefile("${path.module}/connection-blob-access-policy.json", {
    name      = "azureblob/${azurerm_logic_app_standard.logic_app.name}-${azurerm_logic_app_standard.logic_app.identity.0.principal_id}",
    tenant_id = data.azurerm_subscription.current.tenant_id,
    object_id = azurerm_logic_app_standard.logic_app.identity.0.principal_id,
    location  = var.location,
    }
  )
}
