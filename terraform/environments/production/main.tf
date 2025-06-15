module "s3" {
  source        = "../../modules/aws/s3"
  aws_s3_bucket = local.common.pj_name
}
