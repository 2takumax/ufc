data "terraform_remote_state" "scraping" {
  backend = "local"
  config = {
    path = "../scraping/terraform.tfstate"
  }
}

module "integration" {
  source        = "../../../modules/integration"
  aws_account_id = local.common.aws_account_id
  snowflake_iam_role_name = local.common.snowfalake_iam_role_name
  database_name = local.common.pj_name
  bucket_id = data.terraform_remote_state.scraping.outputs.s3_bucket_id
}
