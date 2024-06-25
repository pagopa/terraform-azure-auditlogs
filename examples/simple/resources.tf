resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}


module "azure_auditlogs" {
  source                  = "../.."
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  storage_account_name    = replace("${local.project}st", "-", "")
  storage_container_name  = "auditlogs"
  eventhub_namespace_name = "${local.project}-evhns"
  appi_name               = "${local.project}-appi"
  eventhub_name           = "${local.project}-evh"
  capacity                = 4
  law_name                = "${local.project}-law"
  auto_inflate            = var.auto_inflate
  account_replication     = var.account_replication
  account_tier            = var.account_tier
  access_tier             = var.access_tier
  export_rule_name        = "${local.project}-exp"
  table_names             = var.table_names
  tags                    = var.tags
  stream_job_name         = "${local.project}-job"
}
