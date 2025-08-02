from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# DAG定義
with DAG(
    dag_id="s3_to_snowflake_odds",
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    description="S3 to Snowflake ODDS table ingest via COPY INTO",
    schedule_interval=None,  # 手動またはトリガー実行のみ
    start_date=days_ago(1),
    catchup=False,
    tags=["s3", "snowflake"],
) as dag:

    # S3 → Snowflake テーブルへのデータロード（COPY INTO）
    load_to_snowflake = SnowflakeOperator(
        task_id="copy_into_odds",
        sql="""
        COPY INTO "UFC".PUBLIC."ODDS"
        FROM @"UFC".PUBLIC."external_stage"/fight_odds.csv
        FILE_FORMAT = (FORMAT_NAME = "UFC".PUBLIC."MY_CSV_FORMAT")
        ;
        """,
        snowflake_conn_id="snowflake_okayama",
    )