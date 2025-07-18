resource "snowflake_stage" "external_stage" {
  name        = "external_stage"
  url         = "s3://${var.bucket_id}"
  database    = "${var.database_name}"
  schema      = "PUBLIC"
  storage_integration = snowflake_storage_integration.s3_int.name
}
