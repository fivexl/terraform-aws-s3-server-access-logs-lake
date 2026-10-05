variable "glue_database_name" {
  description = "The name of the Glue database to create for the S3 access logs."
  type        = string
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags"
  type        = map(string)
  default     = {}
}

variable "logs_bucket_lifecycle_rule" {
  type        = any
  description = "The lifecycle rule for the logs bucket"
  default     = {}
}

variable "target_bucket_name" {
  type        = string
  description = "The name of the target bucket. If not provided, the bucket name will be generated based on the region and UUID."
  default     = null
}

variable "target_bucket_access_logs_bucket_name" {
  type        = string
  description = "Name for a backet that would be used to store access logs of the target bucket."
  default     = null
}

# The access logs bucket is created through the account-baseline region_level module, which also
# manages account-wide, per-region EC2/SSM settings. Those are singletons: if the account already
# runs account-baseline region_level (or any other module managing them), set these to false here
# so two Terraform states do not both claim ownership of the same setting.

variable "create_ebs_snapshot_block_public_access" {
  type        = bool
  description = "Whether the access logs bucket module should also manage EBS snapshot block public access for the region. Set to false if another module already manages it."
  default     = true
}

variable "create_ebs_encryption_by_default" {
  type        = bool
  description = "Whether the access logs bucket module should also manage EBS encryption by default for the region. Set to false if another module already manages it."
  default     = true
}

variable "create_ssm_block_public_sharing" {
  type        = bool
  description = "Whether the access logs bucket module should also block public sharing of SSM documents in the region. Set to false if another module already manages it."
  default     = true
}