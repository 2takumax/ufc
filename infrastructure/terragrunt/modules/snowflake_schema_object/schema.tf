# resource "snowflake_schema" "this" {
#   for_each = {
#     for row in var.schema : row["name"] => row
#     if strcontains(row["env"], "${var.env}") || row["env"] == "all"
#   }

#     database = snowflake_database.this["${each.key}"].name
#     name = upper(tostring(split("-", each.key)[1]))
# }
