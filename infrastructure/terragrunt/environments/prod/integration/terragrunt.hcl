include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_parent_terragrunt_dir("root")}/modules/integration"
}

dependency "scraping" {
    config_path = "../scraping"
}

inputs = {
    bucket_id = dependency.scraping.outputs.s3_bucket_id
    database_name = "ufc-fight-prediction"
    snowflake_iam_role_name = "snowflake"
}
