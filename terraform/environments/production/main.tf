module "scraping" {
  source = "../../modules/scraping"
  aws_s3_bucket = local.common.pj_name

}

# module "snowflake" {
#   source = "../../modules/snowflake"
#   lambda_iam_role = module.iam.lambda_iam_role
# }

# module "integration" {
#   source        = "../../modules/integration"
#   database_name = local.common.pj_name
# }
