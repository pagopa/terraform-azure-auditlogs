resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${local.project}-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"

  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "${local.project}-appi"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.this.id

  tags = var.tags
}

module "azure_auditlogs" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account = {
    name                               = replace("${local.project}st", "-", ""),
    immutability_policy_enabled        = false,
    immutability_policy_retention_days = 1,
  }

  event_hub = {
    namespace_name           = "${local.project}-evhns",
    maximum_throughput_units = 1
  }

  log_analytics_workspace = {
    id            = azurerm_log_analytics_workspace.this.id,
    export_tables = ["AppEvents"],
  }

  stream_analytics_job = {
    name            = "${local.project}-job"
    streaming_units = 3
  }

  data_explorer = {
    name         = "${local.project}-dec",
    sku_name     = "Dev(No SLA)_Standard_E2a_v4",
    sku_capacity = 1,
  }

  logic_app = {
    name                 = "${local.project}-logic",
    storage_account_name = "${local.project}-logic-st",
    plan_name            = "${local.project}-logic-asp",
  }

  tags = var.tags
}
