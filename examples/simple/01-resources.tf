# Azure AD
data "azuread_group" "adgroup_admin" {
  display_name = "dvopla-d-adgroup-admin"
}

data "azuread_group" "adgroup_developers" {
  display_name = "dvopla-d-adgroup-developers"
}

data "azuread_group" "adgroup_operations" {
  display_name = "dvopla-d-adgroup-operations"
}

data "azuread_group" "adgroup_security" {
  display_name = "dvopla-d-adgroup-security"
}

data "azuread_group" "adgroup_technical_project_managers" {
  display_name = "dvopla-d-adgroup-technical-project-managers"
}


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

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "private-endpoint-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/23"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_privatelink_blob_core_windows_net" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

module "azure_auditlogs" {
  source                     = "../.."
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  debug                      = true
  subnet_private_endpoint_id = azurerm_subnet.private_endpoint.id

  storage_account = {
    name_temp                          = replace("${local.project}tmpst", "-", ""),
    name_immutable                     = replace("${local.project}immst", "-", ""),
    immutability_policy_enabled        = true,
    immutability_policy_retention_days = 1,
    immutability_policy_state          = "Unlocked" # change to Locked after first apply
  }

  event_hub = {
    namespace_name = "${local.project}-evhns",
    sku_name       = "Standard",
  }

  log_analytics_workspace = {
    id            = azurerm_log_analytics_workspace.this.id,
    export_tables = ["AppEvents"],
  }

  stream_analytics_job = {
    name            = "${local.project}-job"
    streaming_units = 10,
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
