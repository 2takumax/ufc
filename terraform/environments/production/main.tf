module "iam" {
  source = "../../modules/aws/iam"
}

module "lambda" {
  source = "../../modules/aws/lambda"
  lambda_iam_role = module.iam.lambda_iam_role
}

module "snowflake_database" {
  source        = "../../modules/snowflake/database"
  database_name = local.common.pj_name
}
