resource "snowflake_database" "ufc-fight-prediction" {
  name = var.database_name
}

resource "snowflake_schema" "RAW" {
  name     = "RAW"
  database = snowflake_database.ufc-fight-prediction.name
}
