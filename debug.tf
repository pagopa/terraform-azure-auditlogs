resource "azurerm_monitor_diagnostic_setting" "law" {
  count = var.debug ? 1 : 0

  name                       = "debug"
  target_resource_id         = var.log_analytics_workspace.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  enabled_log {
    category_group = "audit"
  }

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "eventhub" {
  count = var.debug ? 1 : 0

  name                       = "debug"
  target_resource_id         = azurerm_eventhub_namespace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  enabled_log {
    category_group = "audit"
  }

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "stream_analytics" {
  count = var.debug ? 1 : 0

  name                       = "debug"
  target_resource_id         = azurerm_stream_analytics_job.this.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_tmp_blob" {
  count = var.debug ? 1 : 0

  name                       = "debug"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default/"
  log_analytics_workspace_id = var.log_analytics_workspace.id

  enabled_log {
    category_group = "audit"
  }

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_imm_blob" {
  count = var.debug ? 1 : 0

  name                       = "debug"
  target_resource_id         = "${azurerm_storage_account.immutable.id}/blobServices/default/"
  log_analytics_workspace_id = var.log_analytics_workspace.id

  enabled_log {
    category_group = "audit"
  }

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
