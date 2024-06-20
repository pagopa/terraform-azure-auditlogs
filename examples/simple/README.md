# terraform-aws-runner: Simple example

Minimal simple example of module usage.
It creates a VPC, a GitHub runner in that VPC, permissions for the runner to list S3 buckets.

This example is linked to this [example action](../../.github/workflows/example-simple.yml) provided in this repository.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | =5.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_githubrunner"></a> [aws\_githubrunner](#module\_aws\_githubrunner) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.list_buckets](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/iam_policy) | resource |
| [aws_security_group.vpc_tls](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name. | `string` | `"ca"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | AWS availabiity zones of subnetsregion to create resources | `list(string)` | <pre>[<br>  "eu-south-1a"<br>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources | `string` | `"eu-south-1"` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Evnironment short. | `string` | `"d"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"dev"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster"></a> [ecs\_cluster](#output\_ecs\_cluster) | ECS task of the runner |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ECS task of the runner |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | ECS task of the runner |
| <a name="output_github_iam_role_arn"></a> [github\_iam\_role\_arn](#output\_github\_iam\_role\_arn) | ARN of the IAM role federated for invoking the runner from a GitHub action |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | IDs of subnets managed |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
