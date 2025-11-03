module "target_bucket" {
  source      = "fivexl/account-baseline/aws//modules/s3_baseline"
  version     = "1.5.0"
  bucket_name = local.target_bucket_name

  logging = {
    target_bucket = var.target_bucket_access_logs_bucket_name != null ? var.target_bucket_access_logs_bucket_name : try(module.target_bucket_access_logs_bucket[0].access_logs_bucket_name, null)
  }

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "BucketLevel",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Condition" : {
            "StringEquals" : {
              "aws:SourceOrgID" : data.aws_organizations_organization.this.id,
            }
          }
          "Action" : ["s3:List*", "s3:GetBucketVersioning", "s3:PutBucketVersioning"],
          "Resource" : "arn:aws:s3:::${local.target_bucket_name}"
        },
        {
          "Sid" : "MemberAccountAccessObjectLevel",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [
            "s3:ReplicateObject",
          ],
          "Condition" : {
            "StringEquals" : {
              "aws:PrincipalOrgID" : data.aws_organizations_organization.this.id,
            }
          },
          "Resource" : "arn:aws:s3:::${local.target_bucket_name}/*",
        },
      ]
    }
  )
  lifecycle_rule = var.logs_bucket_lifecycle_rule

  tags = var.tags
}

module "target_bucket_access_logs_bucket" {
  source  = "fivexl/account-baseline/aws//modules/region_level"
  version = "1.5.0"

  count = var.target_bucket_access_logs_bucket_name != null ? 0 : 1

  s3_access_logs_bucket_name    = local.target_bucket_access_logs_bucket_name
  create_dynamodb_tf_state_lock = false
  create_s3_tf_state_bucket     = false
  tags                          = var.tags
}


module "glue_table" {
  source  = "fivexl/s3-access-logs-athena-table/aws"
  version = "1.0.2"

  name          = local.glue_table_name
  database_name = var.glue_database_name
  location      = "s3://${module.target_bucket.s3_bucket_id}"
}
