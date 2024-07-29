resource "azurerm_storage_account" "immutable" {
  name                             = var.storage_account.name_immutable
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_replication_type         = var.storage_account.account_replication_type
  account_tier                     = "Standard"
  access_tier                      = "Hot"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false

  dynamic "immutability_policy" {
    for_each = var.storage_account.immutability_policy_enabled ? ["enabled"] : []
    content {
      allow_protected_append_writes = true
      period_since_creation_in_days = var.storage_account.immutability_policy_retention_days
      state                         = "Unlocked"
    }
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "immutable" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.immutable.name
  container_access_type = "private"
}

resource "azurerm_storage_object_replication" "temp_immutable" {
  source_storage_account_id      = azurerm_storage_account.this.id
  destination_storage_account_id = azurerm_storage_account.immutable.id
  rules {
    source_container_name      = azurerm_storage_container.this.name
    destination_container_name = azurerm_storage_container.immutable.name
    copy_blobs_created_after   = "Everything"
  }
}
