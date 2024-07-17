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

resource "azurerm_app_service_plan" "logic_app" {
  name                = var.logic_app.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "elastic"

  sku {
    tier = "WorkflowStandard"
    size = var.logic_app.plan_size
    # scale out
  }
  tags = var.tags
}

resource "azurerm_logic_app_standard" "logic_app" {
  name                       = var.logic_app.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.logic_app.id
  storage_account_name       = azurerm_storage_account.logic_app.name
  storage_account_access_key = azurerm_storage_account.logic_app.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~20"
    FUNCTIONS_EXTENSION_VERSION  = "~4"
  }

  https_only = true
  site_config {
    use_32_bit_worker_process = false
  }

  tags = var.tags
}
