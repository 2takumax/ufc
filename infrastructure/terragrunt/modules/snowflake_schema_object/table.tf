resource "snowflake_table" "this" {
  for_each = var.table_map

  database = snowflake_database.this["${tostring(split("-", each.key)[0])}"].name
  schema = upper(tostring(split("-", each.key)[1]))
  name = upper(tostring(split("-", each.key)[2]))
  comment = lookup(each.value, "table_name_jpn", null)

  dynamic "column" {
    for_each = each.value.columns
    content {
      name = column.value.name
      type = column.value.type
      nullable = lookup(column.value, "nullable", true)
      dynamic "identity" {
        for_each = (
          contains(keys(column.value), "start_num") && contains(key(column.value), "step_num")
        ) ? [1] : []
        content {
          start_num = column.value.start_num
          step_num = column.value.step_num
        }
      }
    }
  }
}
