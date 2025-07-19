include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_parent_terragrunt_dir("root")}/modules/scraping"
}

inputs = {
    aws_s3_bucket = "ufc-fight-prediction"
}
