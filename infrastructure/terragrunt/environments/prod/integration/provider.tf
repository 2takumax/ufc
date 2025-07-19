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

  preview_features_enabled = ["snowflake_table_resource", "snowflake_storage_integration_resource", "snowflake_stage_resource", "snowflake_pipe_resource"]
}

variable "password" {
  type = string
  sensitive = true
}
