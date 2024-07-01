resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

module "azure_auditlogs" {
  source                  = "../.."
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  storage_account         = {name = replace("${local.project}st", "-", "")}
  event_hub               = {namespace_name ="${local.project}-evhns", capacity = 4, auto_inflate_enabled = var.auto_inflate_enabled}
  application_insights    = {name = "${local.project}-appi"}
  log_analytics_workspace = {name = "${local.project}-law"}
  account_replication     = var.account_replication
  account_tier            = var.account_tier
  access_tier             = var.access_tier
  export_rule_name        = "${local.project}-exp"
  table_names             = var.table_names
  tags                    = var.tags
  stream_analytics_job    = {name = "${local.project}-job"}
  data_explorer           = {name = "${local.project}-dec", sku_name = var.sku_name, sku_capacity = var.sku_capacity} 
}
