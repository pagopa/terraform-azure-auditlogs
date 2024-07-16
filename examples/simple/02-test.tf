resource "azurerm_service_plan" "this" {
  name                     = "${local.project}-asp"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "P1v3"
  worker_count             = 1
  os_type                  = "Linux"
  per_site_scaling_enabled = false
  zone_balancing_enabled   = false
  tags                     = var.tags
}

resource "azurerm_storage_account" "this" {
  name                     = replace("${local.project}funcst", "-", "")
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_linux_function_app" "this" {
  name                = "${local.project}-func"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name          = azurerm_storage_account.this.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.this.id

  client_certificate_enabled = false
  https_only                 = true

  site_config {
    always_on                              = true
    use_32_bit_worker                      = false
    ftps_state                             = "Disabled"
    http2_enabled                          = true
    minimum_tls_version                    = "1.2"
    scm_minimum_tls_version                = "1.2"
    vnet_route_all_enabled                 = true
    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key

    application_stack {
      node_version = "20"
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]
      support_credentials = false
    }
  }

  app_settings = {
    APPINSIGHTS_SAMPLING_PERCENTAGE = 5
    WEBSITE_RUN_FROM_PACKAGE        = 1
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
}

resource "null_resource" "deploy" {
  depends_on = [azurerm_role_assignment.this]

  triggers = {
    deploy_version = "1.1" # change me to redeploy
    function_name  = azurerm_linux_function_app.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      cd function-app && \
      yarn install && \
      func azure functionapp publish ${self.triggers.function_name}
    EOT
  }
}