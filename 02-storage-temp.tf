resource "azurerm_storage_account" "temp" {
  name                             = var.storage_account.name_temp
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_replication_type         = var.storage_account.account_replication_type
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  allowed_copy_scope               = "AAD"
  default_to_oauth_authentication  = true

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }

  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    private_link_access {
      endpoint_resource_id = azurerm_stream_analytics_job.this.id
      endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    }
    ip_rules = var.debug ? ["0.0.0.0/0"] : []
  }

  tags = var.tags
}

resource "azurerm_storage_container" "temp" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.temp.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "temp" {
  storage_account_id = azurerm_storage_account.temp.id
  rule {
    name    = "delete_rule"
    enabled = true

    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }

    actions {
      version {
        delete_after_days_since_creation = 7
      }
      base_blob {
        delete_after_days_since_creation_greater_than = 7
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 7
      }
    }
  }
}

resource "azurerm_role_assignment" "storage_temp_blob_data_reader_admin" {
  for_each             = toset(var.data_explorer.admin_groups)
  scope                = azurerm_storage_account.temp.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "storage_temp_blob_data_reader_reader" {
  for_each             = toset(var.data_explorer.reader_groups)
  scope                = azurerm_storage_account.temp.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.key
}

resource "azurerm_private_endpoint" "storage_temp_blob" {
  name                = var.storage_account.name_temp
  location            = azurerm_storage_account.temp.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_private_endpoint_id

  private_service_connection {
    name                           = var.storage_account.name_temp
    private_connection_resource_id = azurerm_storage_account.temp.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.storage_account_blob.id]
  }

  tags = var.tags
}
