resource "snowflake_pipe" "pipe" {
  database = "UFC"
  schema   = "PUBLIC"
  name     = "ODDS"

  comment = "A pipe."

  copy_statement = <<-EOT
    COPY INTO "UFC".PUBLIC."ODDS"
    FROM @"UFC".PUBLIC."${snowflake_stage.external_stage.name}"/odds.csv
    FILE_FORMAT = (FORMAT_NAME = "UFC".PUBLIC."MY_CSV_FORMAT")
  EOT
  auto_ingest    = true
}

resource "snowflake_pipe" "fighters_pipe" {
  database = "UFC"
  schema   = "PUBLIC"
  name     = "fighters_pipe"

  comment = "A pipe."

  copy_statement = <<-EOT
    COPY INTO "UFC".PUBLIC."FIGHTERS"
    FROM @"UFC".PUBLIC."${snowflake_stage.external_stage.name}"/fighters.csv
    FILE_FORMAT = (FORMAT_NAME = "UFC".PUBLIC."MY_CSV_FORMAT")
  EOT
  auto_ingest    = true
}
