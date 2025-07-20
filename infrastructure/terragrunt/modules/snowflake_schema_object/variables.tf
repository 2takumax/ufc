variable "env" {
  type = string
  description = "環境名"
}

variable "database" {
  description = "作成するs3のバケット名"
  type        = list(any)
}

# variable "schema" {
#   description = "作成するs3のバケット名"
#   type        = list(any)
# }

variable "table_map" {
  type = map(any)
  description = ""
}
