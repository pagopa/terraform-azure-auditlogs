resource "azurerm_log_analytics_data_export_rule" "this" {
  for_each = toset(var.log_analytics_workspace.export_tables)

  name                    = each.value
  resource_group_name     = var.log_analytics_workspace_rg_name
  workspace_resource_id   = var.log_analytics_workspace.id
  destination_resource_id = azurerm_eventhub.law.id
  table_names             = [each.value]
  enabled                 = true
}
