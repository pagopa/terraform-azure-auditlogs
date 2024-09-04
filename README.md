# terraform-azure-auditlogs

This repository contains a Terraform module and an example for deploying resources needed to store audit logs in a Azure cloud environment. The module is designed to be flexible and scalable, allowing you to securely store and manage audit logs in accordance with your organization's compliance and security requirements.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Module Usage](#module-usage)
  - [Example Deployment](#example-deployment)

## Overview

The Terraform module in this repository provisions the necessary resources for storing audit logs, such as storage account, data export, and logging configurations. The example included demonstrates how to utilize the module in a typical deployment scenario.

Audit log module is based on export logs from Log Analytics Workspace and store them into an immutable storage, as explained into Microsoft docs https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#overview

We use Stream Analytics Job to store only audit logs and Data Explorer to search logs into storage account with immutability policy enabled.


## Features

- Provisioning of storage resources optimized for audit logs
- Configurable retention policies for compliance
- Easily integratable with existing Terraform infrastructure

## Prerequisites

Before using this module, ensure that you have the following:

- Access to Azure Cloud
- Azure CLI
- Terraform installed on your local machine

## Usage

### Module Usage

To use this module in your Terraform configuration, refer to **examples/simple** folder witch contains all you need.

See 02-module.tf file that contains example usage for the module.

For production environment you need:

- set `debug` variable to `false`. This variable enable diagnostic settings and disable network policy, so for production use you myst set to `false`
- set `storage_account.immutability_policy_retention_days` to to required retention (there is also a lifecycle policy to delete logs after 7 days of required retention)
- set `storage_account.immutability_policy_state` to `Locked` after first apply

### Example Deployment

- backend.ini contains the default subscription
- 01-resources.tf file contains all resources used by the the module
- 02-module.tf file contains the module usage for a test env
- 03-test.tf contains load test environment (function app and logic app to generate sample logs)

Run `./terraform apply` to create entire environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>1.15 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.39 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.immutable_approval](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_eventhub.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_kusto_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_cluster_managed_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster_managed_private_endpoint) | resource |
| [azurerm_kusto_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database) | resource |
| [azurerm_kusto_database_principal_assignment.admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database_principal_assignment) | resource |
| [azurerm_kusto_database_principal_assignment.viewer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database_principal_assignment) | resource |
| [azurerm_kusto_script.create_external_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_script) | resource |
| [azurerm_log_analytics_data_export_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_monitor_autoscale_setting.azurerm_stream_analytics_job](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_monitor_diagnostic_setting.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_immutable_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_temp_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.stream_analytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.storage_immutable_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.storage_temp_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.kusto_cluster_blob_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_immutable_blob_data_reader_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_immutable_blob_data_reader_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_temp_blob_data_reader_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_temp_blob_data_reader_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.stream_analytics_azure_event_hubs_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.stream_analytics_azure_storage_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.temp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.temp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_management_policy.temp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_object_replication.temp_immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_object_replication) | resource |
| [azurerm_stream_analytics_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job) | resource |
| [azurerm_stream_analytics_job_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job_schedule) | resource |
| [azurerm_stream_analytics_output_blob.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_output_blob) | resource |
| [azurerm_stream_analytics_stream_input_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_stream_input_eventhub) | resource |
| [azapi_resource.immutable](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_private_dns_zone.storage_account_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_explorer"></a> [data\_explorer](#input\_data\_explorer) | n/a | <pre>object({<br>    name           = string,<br>    sku_name       = string,<br>    sku_capacity   = number,<br>    script_content = optional(string, "external_table.sql"),<br>    reader_groups  = list(string),<br>    admin_groups   = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_debug"></a> [debug](#input\_debug) | n/a | `bool` | `false` | no |
| <a name="input_event_hub"></a> [event\_hub](#input\_event\_hub) | n/a | <pre>object({<br>    namespace_name = string,<br>    sku_name       = optional(string, "Standard"),<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | n/a | <pre>object({<br>    id            = string,<br>    export_tables = list(string),<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | n/a | <pre>object({<br>    name_temp                          = string,<br>    name_immutable                     = string,<br>    account_replication_type           = optional(string, "ZRS"),<br>    immutability_policy_enabled        = bool,<br>    immutability_policy_retention_days = number,<br>    immutability_policy_state          = string,<br>  })</pre> | n/a | yes |
| <a name="input_stream_analytics_job"></a> [stream\_analytics\_job](#input\_stream\_analytics\_job) | n/a | <pre>object({<br>    name                 = string,<br>    transformation_query = optional(string, "transformation_query.sql"),<br>  })</pre> | n/a | yes |
| <a name="input_subnet_private_endpoint_id"></a> [subnet\_private\_endpoint\_id](#input\_subnet\_private\_endpoint\_id) | Private endpoint subnet id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
