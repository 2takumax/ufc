resource "snowflake_file_format" "csv_format" {
  name                  = "MY_CSV_FORMAT"
  database = "UFC"
  schema = "PUBLIC"
  format_type                  = "CSV"
  field_delimiter       = ","
  skip_header           = 1
  field_optionally_enclosed_by = "\""
}
