module "azure_auditlogs" {
  depends_on = [azurerm_private_dns_zone.privatelink_blob_core_windows_net] # only for test env

  source                     = "../.."
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  debug                      = true # true only for test use, set to false in production envs
  subnet_private_endpoint_id = azurerm_subnet.private_endpoint.id

  storage_account = {
    name_temp                          = replace("${local.project}tmpst", "-", ""),
    name_immutable                     = replace("${local.project}immst", "-", ""),
    immutability_policy_enabled        = true,
    immutability_policy_retention_days = 1,          # change to required retention
    immutability_policy_state          = "Unlocked", # change to Locked after first apply
  }

  event_hub = {
    namespace_name = "${local.project}-evhns",
    sku_name       = "Standard", # change to Premium for mission critical applications
  }

  log_analytics_workspace = {
    id            = azurerm_log_analytics_workspace.this.id,
    export_tables = ["AppEvents"], # change to appropriate log analytics table
  }

  stream_analytics_job = {
    name = "${local.project}-job",
  }

  data_explorer = {
    name          = "${local.project}-dec",
    sku_name      = "Dev(No SLA)_Standard_E2a_v4",
    sku_capacity  = 1,
    reader_groups = [data.azuread_group.adgroup_security.object_id, data.azuread_group.adgroup_operations.object_id, data.azuread_group.adgroup_technical_project_managers.object_id],
    admin_groups  = [data.azuread_group.adgroup_admin.object_id, data.azuread_group.adgroup_developers.object_id],
  }

  tags = var.tags
}
