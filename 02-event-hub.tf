resource "azurerm_eventhub_namespace" "this" {
  name                          = var.event_hub.namespace_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.event_hub.sku_name
  local_authentication_enabled  = false
  minimum_tls_version           = "1.2"
  auto_inflate_enabled          = var.event_hub.sku_name == "Standard" ? true : null
  maximum_throughput_units      = var.event_hub.sku_name == "Standard" ? 40 : null
  public_network_access_enabled = false

  network_rulesets {
    default_action                 = "Allow"
    public_network_access_enabled  = false
    trusted_service_access_enabled = true
    ip_rule                        = []
    virtual_network_rule           = []
  }

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
  partition_count     = var.event_hub.sku_name == "Standard" ? 32 : 100
  message_retention   = var.event_hub.sku_name == "Standard" ? 7 : 90
}
