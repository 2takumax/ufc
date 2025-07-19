include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_parent_terragrunt_dir("root")}/modules/snowflake_schema_object"
}

inputs = {
    database_name = "ufc-fight-prediction"
}
