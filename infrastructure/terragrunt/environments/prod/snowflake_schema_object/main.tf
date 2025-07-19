module "snowflake_schema_object" {
  source = "../../../modules/snowflake_schema_object"
  database_name = local.common.pj_name
}
