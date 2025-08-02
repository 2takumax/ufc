from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# DAG定義
with DAG(
    dag_id="s3_to_snowflake_event_details",
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    description="S3 to Snowflake EVENT_DETAILS table ingest via COPY INTO",
    schedule_interval=None,  # 手動またはトリガー実行のみ
    start_date=days_ago(1),
    catchup=False,
    tags=["s3", "snowflake"],
) as dag:

    # S3 → Snowflake テーブルへのデータロード（COPY INTO）
    load_to_snowflake = SnowflakeOperator(
        task_id="copy_into_event_details",
        sql="""
        COPY INTO "UFC".PUBLIC."EVENT_DETAILS"
        FROM @"UFC".PUBLIC."external_stage"/event_details.csv
        FILE_FORMAT = (FORMAT_NAME = "UFC".PUBLIC."MY_CSV_FORMAT")
        ;
        """,
        snowflake_conn_id="snowflake_okayama",
    )