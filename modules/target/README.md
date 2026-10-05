# Terraform AWS S3 Server Access Logs Target Module
This module creates an S3 bucket for storing access logs from other S3 buckets.

### Features:
- Creates an S3 bucket using FivexL's `s3_baseline` module to be used as a target for replicating logs from other accounts in the organization.
- Creates a bucket policy that allows the replication of logs from other accounts in the organization.

### Usage:
This module is intended to be deployed in the log-archive account, and the bucket from this module should be used as a target for replicating logs from other accounts in the organization.
Other accounts in the organization will only be able to write logs to their own prefix in the bucket ("arn:aws:s3:::${bucket_name}/$${aws:PrincipalAccount}/*").
The module also creates a Glue table for querying logs with Athena.

### Examples:

```hcl
resource "aws_glue_catalog_database" "s3_access_logs_primary" {
  name = "s3_access_logs"
}

module "s3_server_access_logs_lake_primary" {
  source = "fivexl/s3-server-access-logs-lake/aws//modules/target"

  glue_database_name         = aws_glue_catalog_database.s3_access_logs_primary.name
  tags                       = module.tags.result
  logs_bucket_lifecycle_rule = local.logs_bucket_lifecycle_rule
}

resource "aws_glue_catalog_database" "s3_access_logs_secondary" {
  name = "s3_access_logs"

  provider = aws.secondary
}

module "s3_server_access_logs_lake_secondary" {
  source = "fivexl/s3-server-access-logs-lake/aws//modules/target"

  glue_database_name = aws_glue_catalog_database.s3_access_logs_secondary.name
  tags               = module.tags.result
  providers          = { aws = aws.secondary }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_glue_table"></a> [glue\_table](#module\_glue\_table) | fivexl/s3-access-logs-athena-table/aws | 1.0.1 |
| <a name="module_naming_conventions"></a> [naming\_conventions](#module\_naming\_conventions) | ../../../naming_conventions | n/a |
| <a name="module_target_bucket"></a> [target\_bucket](#module\_target\_bucket) | fivexl/account-baseline/aws//modules/s3_baseline | 1.2.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_ebs_encryption_by_default"></a> [create\_ebs\_encryption\_by\_default](#input\_create\_ebs\_encryption\_by\_default) | Whether the access logs bucket module should also manage EBS encryption by default for the region. Set to false if another module already manages it. | `bool` | `true` | no |
| <a name="input_create_ebs_snapshot_block_public_access"></a> [create\_ebs\_snapshot\_block\_public\_access](#input\_create\_ebs\_snapshot\_block\_public\_access) | Whether the access logs bucket module should also manage EBS snapshot block public access for the region. Set to false if another module already manages it. | `bool` | `true` | no |
| <a name="input_create_ssm_block_public_sharing"></a> [create\_ssm\_block\_public\_sharing](#input\_create\_ssm\_block\_public\_sharing) | Whether the access logs bucket module should also block public sharing of SSM documents in the region. Set to false if another module already manages it. | `bool` | `true` | no |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | The name of the Glue database to create for the S3 access logs. | `string` | n/a | yes |
| <a name="input_logs_bucket_lifecycle_rule"></a> [logs\_bucket\_lifecycle\_rule](#input\_logs\_bucket\_lifecycle\_rule) | The lifecycle rule for the logs bucket | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
