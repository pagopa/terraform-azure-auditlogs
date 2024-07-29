# terraform-azure-auditlogs<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.39 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.filtered](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_kusto_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database) | resource |
| [azurerm_kusto_database_principal_assignment.admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database_principal_assignment) | resource |
| [azurerm_kusto_database_principal_assignment.viewer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database_principal_assignment) | resource |
| [azurerm_kusto_script.create_external_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_script) | resource |
| [azurerm_log_analytics_data_export_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_role_assignment.kusto_cluster_blob_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_blob_data_reader_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_blob_data_reader_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.stream_analytics_azure_event_hubs_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.stream_analytics_azure_event_hubs_data_sender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.immutable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_stream_analytics_function_javascript_udf.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_function_javascript_udf) | resource |
| [azurerm_stream_analytics_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job) | resource |
| [azurerm_stream_analytics_job_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job_schedule) | resource |
| [azurerm_stream_analytics_output_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_output_eventhub) | resource |
| [azurerm_stream_analytics_stream_input_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_stream_input_eventhub) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_explorer"></a> [data\_explorer](#input\_data\_explorer) | n/a | <pre>object({<br>    name           = string,<br>    sku_name       = string,<br>    sku_capacity   = number,<br>    tenant_id      = string,<br>    script_content = optional(string, "external_table.sql"),<br>    reader_groups  = list(string),<br>    admin_groups   = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_event_hub"></a> [event\_hub](#input\_event\_hub) | n/a | <pre>object({<br>    namespace_name           = string,<br>    maximum_throughput_units = number,<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | n/a | <pre>object({<br>    id            = string,<br>    export_tables = list(string),<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | n/a | <pre>object({<br>    name_temp                          = string,<br>    name_immutable                     = string,<br>    account_replication_type           = optional(string, "ZRS"),<br>    immutability_policy_enabled        = bool,<br>    immutability_policy_retention_days = number,<br>  })</pre> | n/a | yes |
| <a name="input_stream_analytics_job"></a> [stream\_analytics\_job](#input\_stream\_analytics\_job) | n/a | <pre>object({<br>    name                 = string,<br>    streaming_units      = number,<br>    transformation_query = optional(string, "transformation_query.sql"),<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
