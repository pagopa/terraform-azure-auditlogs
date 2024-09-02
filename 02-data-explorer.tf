resource "azurerm_kusto_cluster" "this" {
  name                = var.data_explorer.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.data_explorer.sku_name
    capacity = var.data_explorer.sku_capacity
  }

  identity {
    type = "SystemAssigned"
  }

  zones = ["1", "2", "3"]

  tags = var.tags
}

resource "azurerm_role_assignment" "kusto_cluster_blob_reader" {
  scope                = azurerm_storage_account.immutable.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_kusto_cluster.this.identity.0.principal_id
}

resource "azurerm_kusto_database" "this" {
  name                = "audit-logs"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = azurerm_kusto_cluster.this.name

  hot_cache_period   = "P7D"
  soft_delete_period = "P30D"
}

resource "azurerm_kusto_script" "create_external_table" {
  name        = "create-external-table"
  database_id = azurerm_kusto_database.this.id
  script_content = templatefile("${path.module}/${var.data_explorer.script_content}", {
    storage_account_name           = azurerm_storage_account.immutable.name,
    storage_account_container_name = azurerm_storage_container.immutable.name
    }
  )
}

resource "azurerm_kusto_database_principal_assignment" "admin" {
  for_each            = toset(var.data_explorer.admin_groups)
  name                = "Admin-${azurerm_kusto_database.this.name}-${each.key}"
  resource_group_name = var.resource_group_name
  cluster_name        = azurerm_kusto_cluster.this.name
  database_name       = azurerm_kusto_database.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  principal_id        = each.key
  principal_type      = "Group"
  role                = "Admin"
}

resource "azurerm_kusto_database_principal_assignment" "viewer" {
  for_each            = toset(var.data_explorer.reader_groups)
  name                = "Viewer-${azurerm_kusto_database.this.name}-${each.key}"
  resource_group_name = var.resource_group_name
  cluster_name        = azurerm_kusto_cluster.this.name
  database_name       = azurerm_kusto_database.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  principal_id        = each.key
  principal_type      = "Group"
  role                = "Viewer"
}

resource "azurerm_kusto_cluster_managed_private_endpoint" "this" {
  name                         = var.data_explorer.name
  resource_group_name          = var.resource_group_name
  cluster_name                 = azurerm_kusto_cluster.this.name
  private_link_resource_id     = azurerm_storage_account.immutable.id
  private_link_resource_region = azurerm_storage_account.immutable.location
  group_id                     = "blob"
}

# Retrieve the storage account details, including the private endpoint connections
data "azapi_resource" "immutable" {
  depends_on = [azurerm_kusto_cluster_managed_private_endpoint.this]

  type                   = "Microsoft.Storage/storageAccounts@2022-09-01"
  resource_id            = azurerm_storage_account.immutable.id
  response_export_values = ["properties.privateEndpointConnections"]
}

# Retrieve the private endpoint connection name from the storage account based on the private endpoint name
locals {
  private_endpoint_connection_name = element([
    for connection in jsondecode(data.azapi_resource.immutable.output).properties.privateEndpointConnections
    : connection.name
    if endswith(connection.properties.privateEndpoint.id, azurerm_kusto_cluster_managed_private_endpoint.this.name)
  ], 0)
}

# Approve the private endpoint
resource "azapi_update_resource" "immutable_approval" {
  depends_on = [azurerm_kusto_cluster_managed_private_endpoint.this]

  type      = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"
  name      = local.private_endpoint_connection_name
  parent_id = azurerm_storage_account.immutable.id

  body = jsonencode({
    properties = {
      privateLinkServiceConnectionState = {
        description = "Approved via Terraform"
        status      = "Approved"
      }
    }
  })
}
