resource "snowflake_database" "this" {
  for_each = {
    for row in var.database : row["name"] => row
    if strcontains(row["env"], "${var.env}") || row["env"] == "all"
  }

  name = upper(each.key)
}
