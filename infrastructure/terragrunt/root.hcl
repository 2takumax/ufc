locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  env = local.environment_vars.locals
}

remote_state {
    backend = "s3"

    generate = {
        path = "backend.tf"
        if_exists = "overwrite"
    }

    config = {
        bucket = "ufc-fight-prediction-prod-terraform-state"
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = "ap-northeast-1"
        encrypt = true
        use_lockfile = true
    }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflakedb/snowflake"
      version = "2.1.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "snowflake" {
  password          = var.password
  role              = "ACCOUNTADMIN"

  preview_features_enabled = ["snowflake_table_resource", "snowflake_storage_integration_resource", "snowflake_stage_resource", "snowflake_pipe_resource", "snowflake_file_format_resource"]
}

variable "password" {
  type = string
  sensitive = true
}
EOF
}