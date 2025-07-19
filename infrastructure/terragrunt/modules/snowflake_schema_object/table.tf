resource "snowflake_table" "fight_stats" {
  name     = "fight_stats"
  database = snowflake_database.ufc-fight-prediction.name
  schema   = "PUBLIC"

  column {
    name = "EVENT"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "BOUT"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "ROUND"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "FIGHTER"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "KD"
    type = "NUMBER(38,0)"
  }

  column {
    name = "SIG_STR"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SIG_STR_RATE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "TOTAL_STR"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "TD"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "TD_RATE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SUB_ATT"
    type = "NUMBER(38,0)"
  }

  column {
    name = "REV"
    type = "NUMBER(38,0)"
  }

  column {
    name = "CTRL"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "HEAD"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "BODY"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "LEG"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DISTANCE"
    type = "NUMBER(38,0)"
  }

  column {
    name = "CLINCH"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "GROUND"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DATE"
    type = "DATE"
  }

  column {
    name = "LOCATION"
    type = "VARCHAR(16777216)"
  }
}