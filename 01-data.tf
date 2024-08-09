data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_private_dns_zone" "storage_account_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.debug ? var.resource_group_name : null
}
