resource "snowflake_database" "ufc-fight-prediction" {
  name = var.database_name
}

# resource "snowflake_schema" "RAW" {
#   name     = "PUBLIC"
#   database = snowflake_database.ufc-fight-prediction.name
# }
