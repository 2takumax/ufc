module "scraping" {
  source = "../../modules/scraping"
  aws_s3_bucket = local.common.pj_name
}

module "snowflake_schema_object" {
  source = "../../modules/snowflake_schema_object"
  database_name = local.common.pj_name
}

module "integration" {
  source        = "../../modules/integration"
  aws_account_id = local.common.aws_account_id
  snowflake_iam_role_name = local.common.snowfalake_iam_role_name
  database_name = local.common.pj_name
  bucket_id = module.scraping.s3_bucket_id
}
