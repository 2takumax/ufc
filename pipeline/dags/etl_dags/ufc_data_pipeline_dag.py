from airflow import DAG
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# DAG定義
default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# 統合パイプラインDAG
with DAG(
    dag_id="ufc_data_pipeline",
    default_args=default_args,
    description="Complete UFC data pipeline: Lambda scraping -> S3 -> Snowflake",
    schedule_interval="0 21 * * 0",  # 毎週月曜日の朝6時JST (日曜21時UTC)
    start_date=days_ago(1),
    catchup=False,
    tags=["pipeline", "ufc", "end-to-end"],
) as dag:

    # ステップ1: Lambda関数でスクレイピング実行
    scrape_events = LambdaInvokeFunctionOperator(
        task_id="scrape_events",
        function_name="prod-scrape_events",
        invocation_type="RequestResponse",
        payload="{}",
        aws_conn_id="aws_default",
    )

    scrape_odds = LambdaInvokeFunctionOperator(
        task_id="scrape_odds",
        function_name="prod-scrape_odds",
        invocation_type="RequestResponse",
        payload="{}",
        aws_conn_id="aws_default",
    )

    # ステップ2: S3からSnowflakeへデータロード
    load_event_details = TriggerDagRunOperator(
        task_id="load_event_details_to_snowflake",
        trigger_dag_id="s3_to_snowflake_event_details",
        wait_for_completion=True,
        poke_interval=60,
    )

    load_fight_details = TriggerDagRunOperator(
        task_id="load_fight_details_to_snowflake",
        trigger_dag_id="s3_to_snowflake_fight_details",
        wait_for_completion=True,
        poke_interval=60,
    )

    load_fight_results = TriggerDagRunOperator(
        task_id="load_fight_results_to_snowflake",
        trigger_dag_id="s3_to_snowflake_fight_results",
        wait_for_completion=True,
        poke_interval=60,
    )

    load_fight_stats = TriggerDagRunOperator(
        task_id="load_fight_stats_to_snowflake",
        trigger_dag_id="s3_to_snowflake_fight_stats",
        wait_for_completion=True,
        poke_interval=60,
    )

    load_fighters = TriggerDagRunOperator(
        task_id="load_fighters_to_snowflake",
        trigger_dag_id="s3_to_snowflake_fighters",
        wait_for_completion=True,
        poke_interval=60,
    )

    load_odds = TriggerDagRunOperator(
        task_id="load_odds_to_snowflake",
        trigger_dag_id="s3_to_snowflake_odds",
        wait_for_completion=True,
        poke_interval=60,
    )

    # ステップ3: dbt実行（オプション）
    run_dbt = SnowflakeOperator(
        task_id="run_dbt_transformations",
        sql="""
        -- dbt transformationsをトリガー
        -- 実際のdbt実行は別のDAGまたはSnowflake内で実行
        CALL SYSTEM$TASK_RUNTIME_INFO('dbt transformation triggered');
        """,
        snowflake_conn_id="snowflake_okayama",
    )

    # 依存関係の定義
    # Lambda関数の実行（並列）
    [scrape_events, scrape_odds]
    
    # Eventsスクレイピング完了後、関連テーブルをロード
    scrape_events >> [load_event_details, load_fight_details, load_fight_results, load_fight_stats, load_fighters]
    
    # Oddsスクレイピング完了後、oddsテーブルをロード
    scrape_odds >> load_odds
    
    # すべてのデータロード完了後、dbt実行
    [load_event_details, load_fight_details, load_fight_results, load_fight_stats, load_fighters, load_odds] >> run_dbt