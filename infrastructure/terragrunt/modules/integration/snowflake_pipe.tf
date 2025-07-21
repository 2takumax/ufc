resource "snowflake_pipe" "pipe" {
  database = "UFC"
  schema   = "PUBLIC"
  name     = "fight_stats_pipe"

  comment = "A pipe."

  copy_statement = <<-EOT
    COPY INTO "UFC".PUBLIC."ODDS"
    FROM @"UFC".PUBLIC."${snowflake_stage.external_stage}"/odds.csv
    FILE_FORMAT = (TYPE = 'CSV')
  EOT
  auto_ingest    = true
}
