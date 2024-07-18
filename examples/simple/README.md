# terraform-aws-runner: Simple example

Minimal simple example of module usage.
It creates a VPC, a GitHub runner in that VPC, permissions for the runner to list S3 buckets.

This example is linked to this [example action](../../.github/workflows/example-simple.yml) provided in this repository.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 1.14.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.39 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_auditlogs"></a> [azure\_auditlogs](#module\_azure\_auditlogs) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_logic_app_action_http.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_http) | resource |
| [azurerm_logic_app_trigger_recurrence.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_recurrence) | resource |
| [azurerm_logic_app_workflow.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [null_resource.deploy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"italynorth"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"adl-t-itn"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Audit Log Solution | `map(string)` | <pre>{<br>  "CreatedBy": "Terraform",<br>  "Description": "Support Request with Stram Analytics and Immutability"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
