from airflow import DAG
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# DAG定義
default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# DAG定義
with DAG(
    dag_id="invoke_scraping_lambdas",
    default_args=default_args,
    description="Invoke Lambda functions for UFC data scraping",
    schedule_interval="0 21 * * 0",  # 毎週月曜日の朝6時JST (日曜21時UTC)
    start_date=days_ago(1),
    catchup=False,
    tags=["lambda", "scraping", "ufc"],
) as dag:

    # UFC Events Lambda関数を呼び出す
    invoke_events_lambda = LambdaInvokeFunctionOperator(
        task_id="invoke_scrape_events_lambda",
        function_name="prod-scrape_events",  # Lambda関数名
        invocation_type="RequestResponse",
        payload="{}",  # 空のペイロード
        aws_conn_id="aws_default",
    )

    # UFC Odds Lambda関数を呼び出す
    invoke_odds_lambda = LambdaInvokeFunctionOperator(
        task_id="invoke_scrape_odds_lambda",
        function_name="prod-scrape_odds",  # Lambda関数名
        invocation_type="RequestResponse",
        payload="{}",  # 空のペイロード
        aws_conn_id="aws_default",
    )

    # 並列実行（両方のLambda関数を同時に実行）
    [invoke_events_lambda, invoke_odds_lambda]