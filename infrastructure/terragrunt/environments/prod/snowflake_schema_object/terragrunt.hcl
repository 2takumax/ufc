include "root" {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "${get_parent_terragrunt_dir("root")}/modules/snowflake_schema_object"
}

locals {
    table_files = fileset("${get_parent_terragrunt_dir("root")}/environments/parameters/snowflake_system_schema_object/table", "**/*.json")

    table_map = {
        for file in local.table_files:
        replace(replace(file, ".json", ""), "/", "-") => jsondecode(file("${get_parent_terragrunt_dir("root")}/environments/parameters/snowflake_system_schema_object/table/${file}"))
    }
}

generate "schema_object_maps" {
    path = "schema_object_maps.auto.tfvars"
    if_exists = "overwrite"
    contents = <<-EOF
        table_map = ${jsonencode(local.table_map)}
    EOF
}

inputs = {
    database = csvdecode(file("${get_parent_terragrunt_dir("root")}/environments/parameters/snowflake_system_schema_object/database/database.csv"))
}
