include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_parent_terragrunt_dir("root")}/modules/mwaa"
}

inputs = {
    airflow_version = "2.10.3"
    account_id = "130870719803"
    private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
    region = "ap-northeast-1"
    source_bucket_name    = "ufc-mwaa"
}
