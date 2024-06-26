# terraform-azure-auditlogs<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.adl_appi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_eventhub.adl-t-itn-evh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.evh-consumer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.adl-t-itn-evhns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_log_analytics_data_export_rule.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_log_analytics_workspace.adl_law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_role_assignment.role-evh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.role-stg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.adltitnexportlaw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.auditlogs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_stream_analytics_job.streamjob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job) | resource |
| [azurerm_stream_analytics_job_schedule.job-schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job_schedule) | resource |
| [azurerm_stream_analytics_output_blob.stream-output](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_output_blob) | resource |
| [azurerm_stream_analytics_stream_input_eventhub.stream-input](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_stream_input_eventhub) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Specifies the access tier for the Storage account | `string` | n/a | yes |
| <a name="input_account_replication"></a> [account\_replication](#input\_account\_replication) | Specifies the replication for the Storage account | `string` | n/a | yes |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Specifies the account tier for the Storage account | `string` | n/a | yes |
| <a name="input_app_insight_exists"></a> [app\_insight\_exists](#input\_app\_insight\_exists) | Specifies if the Application Insight already exists | `bool` | `false` | no |
| <a name="input_appi_name"></a> [appi\_name](#input\_appi\_name) | Specifies the name for the Application Insight | `string` | n/a | yes |
| <a name="input_auto_inflate"></a> [auto\_inflate](#input\_auto\_inflate) | Specifies if the autoscale is enabled or not for the Event hub Namespace | `bool` | n/a | yes |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Specifies the Throughput unit for the Event Hub | `number` | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Specifies the EventHub Name | `string` | n/a | yes |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | Specifies the Eventhub namespace name | `string` | n/a | yes |
| <a name="input_export_rule_name"></a> [export\_rule\_name](#input\_export\_rule\_name) | Specifies the name for the export rule | `string` | n/a | yes |
| <a name="input_file_path"></a> [file\_path](#input\_file\_path) | n/a | `string` | n/a | yes |
| <a name="input_law_exists"></a> [law\_exists](#input\_law\_exists) | Specifies if the log analytics already exists | `bool` | `false` | no |
| <a name="input_law_name"></a> [law\_name](#input\_law\_name) | Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_law_sku"></a> [law\_sku](#input\_law\_sku) | Specifies the SKU for the Log Analytics Workspace | `string` | `"PerGB2018"` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Specifies the storage account name | `string` | n/a | yes |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Specifies the storage account container name | `string` | n/a | yes |
| <a name="input_stream_job_name"></a> [stream\_job\_name](#input\_stream\_job\_name) | n/a | `string` | n/a | yes |
| <a name="input_table_names"></a> [table\_names](#input\_table\_names) | Specifies the Table to be exported | `list(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lawname"></a> [lawname](#output\_lawname) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
