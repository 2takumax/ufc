resource "snowflake_pipe" "pipe" {
  database = "ufc-fight-prediction"
  schema   = "PUBLIC"
  name     = "fight_stats_pipe"

  comment = "A pipe."

  copy_statement = <<-EOT
    COPY INTO "ufc-fight-prediction".PUBLIC."fight_stats"
    FROM @"ufc-fight-prediction".PUBLIC."external_stage"/ufc_fight_stats.csv
    FILE_FORMAT = (TYPE = 'CSV')
  EOT
  auto_ingest    = true
}
