output "lawname" {
  value = azurerm_log_analytics_workspace.adl_law[0].name
}

output "storage_account_name" {
  value = azurerm_storage_account.adltitnexportlaw.name
}
