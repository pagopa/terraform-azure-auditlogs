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
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~20"
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

data "azurerm_managed_api" "eventhubs" {
  name     = "eventhubs"
  location = var.location
}

resource "azurerm_api_connection" "eventhubs" {
  name                = "eventhubs"
  resource_group_name = var.resource_group_name
  managed_api_id      = data.azurerm_managed_api.eventhubs.id
  display_name        = "event-hub"

  tags = var.tags
}

resource "azurerm_api_connection" "eventhubs_3" {
  name                = "eventhubs-3"
  resource_group_name = var.resource_group_name
  managed_api_id      = data.azurerm_managed_api.eventhubs.id
  display_name        = "event-hub-3"

  parameter_values = {
    name = "managedIdentityAuth"
  }

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azapi_resource" "eventhubs_2" {
  type = "Microsoft.Web/connections@2016-06-01"
  name = "eventhubs-2"
  location = var.location
  parent_id = data.azurerm_resource_group.this.id
  tags = var.tags
  body = jsonencode({
    properties = {
      api = {
        brandColor = "#c4d5ff"
        description = "Connect to Azure Event Hubs to send and receive events."
        displayName = "Event Hubs"
        iconUri = "https://connectoricons-prod.azureedge.net/releases/v1.0.1694/1.0.1694.3752/eventhubs/icon.png"
        id = "/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/providers/Microsoft.Web/locations/italynorth/managedApis/eventhubs"
        name = "eventhubs"
        type = "Microsoft.Web/locations/managedApis"
      }
      displayName = "event-hub-2"
      parameterValues = {
        name = "managedIdentityAuth"
      }
    }
  })
}

resource "azurerm_resource_group_template_deployment" "eventhubs_4" {
  name                = "eventhubs-4"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  deployment_mode     = "Incremental" # DO NOT CHANGE OTHERWISE YOU CAN ACCIDENTLY DELETE AZ RESOURCES
  template_content    = <<TEMPLATE
  {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [{
      "apiVersion": "2016-06-01",
      "kind": "V2",
      "properties": {
          "displayName": "eventhubs-4",
        "parameterValueSet": {
            "name": "managedIdentityAuth",
            "values": {
                "namespaceEndpoint": {
                    "value": "sb://adl-t-itn-b65160-evhns.servicebus.windows.net"
                }
            }
        },
          "customParameterValues": {},
          "api": {
            "name": "eventhubs",
            "displayName": "Event Hubs",
            "description": "Connect to Azure Event Hubs to send and receive events.",
            "iconUri": "https://connectoricons-prod.azureedge.net/releases/v1.0.1694/1.0.1694.3752/eventhubs/icon.png",
            "brandColor": "#c4d5ff",
            "category": "Standard",
            "id": "/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/providers/Microsoft.Web/locations/italynorth/managedApis/eventhubs",
            "type": "Microsoft.Web/locations/managedApis"
          },
          "testLinks": [],
          "testRequests": []
      },
      "id": "/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/resourceGroups/adl-t-itn-b65160-rg/providers/Microsoft.Web/connections/eventhubs-4",
      "name": "eventhubs-4",
      "type": "Microsoft.Web/connections",
      "location": "italynorth"
    }]
}
TEMPLATE
}

# resource "azapi_resource" "eventhubs" {
#   type = "Microsoft.Web/connections@2016-06-01"
#   name = "eventhubs"
#   location = var.location
#   parent_id = data.azurerm_resource_group.this.id
#   tags = var.tags
#   body = jsonencode({
#     properties = {
#       api = {
#         brandColor = "#c4d5ff"
#         description = "Connect to Azure Event Hubs to send and receive events."
#         displayName = "Event Hubs"
#         iconUri = "https://connectoricons-prod.azureedge.net/releases/v1.0.1694/1.0.1694.3752/eventhubs/icon.png"
#         id = "/subscriptions/ac17914c-79bf-48fa-831e-1359ef74c1d5/providers/Microsoft.Web/locations/italynorth/managedApis/eventhubs"
#         name = "eventhubs"
#         type = "Microsoft.Web/locations/managedApis"
#       }
#       displayName = "event-hub"
#       parameterValues = {
#         name = "managedIdentityAuth"
#         values = {
#           namespaceEndpoint = {
#             value = "sb://adl-t-itn-b65160-evhns.servicebus.windows.net"
#           }
#         }
#       }
#     #   "parameterValueSet": {
#     #         "name": "managedIdentityAuth",
#     #         "values": {
#     #             "namespaceEndpoint": {
#     #                 "value": "sb://adl-t-itn-b65160-evhns.servicebus.windows.net"
#     #             }
#     #         }
#     #     },
#     }
#   })
# }
