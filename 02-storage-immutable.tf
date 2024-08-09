resource "azurerm_storage_account" "immutable" {
  name                             = var.storage_account.name_immutable
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_replication_type         = var.storage_account.account_replication_type
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  allowed_copy_scope               = "AAD"
  default_to_oauth_authentication  = true

  dynamic "immutability_policy" {
    for_each = var.storage_account.immutability_policy_enabled ? ["enabled"] : []
    content {
      allow_protected_append_writes = true
      period_since_creation_in_days = var.storage_account.immutability_policy_retention_days
      state                         = var.storage_account.immutability_policy_state
    }
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }

  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.debug ? ["0.0.0.0/0"] : []
  }

  tags = var.tags
}

resource "azurerm_storage_container" "immutable" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.immutable.name
  container_access_type = "private"
}

resource "azurerm_storage_object_replication" "temp_immutable" {
  source_storage_account_id      = azurerm_storage_account.temp.id
  destination_storage_account_id = azurerm_storage_account.immutable.id
  rules {
    source_container_name      = azurerm_storage_container.temp.name
    destination_container_name = azurerm_storage_container.immutable.name
    copy_blobs_created_after   = "Everything"
  }
}

resource "azurerm_storage_management_policy" "immutable" {
  storage_account_id = azurerm_storage_account.immutable.id
  rule {
    name    = "delete_rule"
    enabled = true

    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }

    actions {
      version {
        delete_after_days_since_creation = var.storage_account.immutability_policy_retention_days + 7
      }
      base_blob {
        delete_after_days_since_creation_greater_than = var.storage_account.immutability_policy_retention_days + 7
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_account.immutability_policy_retention_days + 7
      }
    }
  }
}

resource "azurerm_role_assignment" "storage_immutable_blob_data_reader_admin" {
  for_each             = toset(var.data_explorer.admin_groups)
  scope                = azurerm_storage_account.immutable.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "storage_immutable_blob_data_reader_reader" {
  for_each             = toset(var.data_explorer.reader_groups)
  scope                = azurerm_storage_account.immutable.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.key
}

resource "azurerm_private_endpoint" "storage_immutable_blob" {
  name                = var.storage_account.name_immutable
  location            = azurerm_storage_account.immutable.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_private_endpoint_id

  private_service_connection {
    name                           = var.storage_account.name_immutable
    private_connection_resource_id = azurerm_storage_account.immutable.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.storage_account_blob.id]
  }

  tags = var.tags
}
