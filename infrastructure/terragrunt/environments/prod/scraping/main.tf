module "scraping" {
  source = "../../../modules/scraping"
  aws_s3_bucket = local.common.pj_name
}
