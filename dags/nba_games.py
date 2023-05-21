from datetime import datetime
from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator




from datetime import timedelta, datetime

##########################################
# Variables (Airflow variables)
##########################################

AWS_CONN_ID = Variable.get("aws_conn_id")
PG_CONN_ID = Variable.get("pg_conn_id")

##########################################
# DAG Setup
##########################################

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    'email_on_retry': False,
    "retries": 0,
    "execution_timeout": timedelta(minutes=480),
    "dagrun_timeout": timedelta(minutes=480),
}

dag = DAG(
    "nba_games",
    default_args=default_args,
    description="Gets the data of NBA games for a single day",
    tags=["etl"],
    schedule_interval='@daily',
    start_date=datetime(2023,3,23),
    catchup=False,
)

##########################################
# Tasks
##########################################

start_operator = EmptyOperator(task_id='begin_execution',  dag=dag)

pull_game_data = BashOperator(
    task_id='pull_game_data',
    bash_command='baskref -t g -d {{ custom_ds | ds }} -fp datasets',
    dag=dag,
)

# TODO: if baskref would allow saving directly onto S3 this task could be avoided
save_to_s3 = BashOperator(
    task_id='save_to_s3',
    bash_command='aws s3 cp datasets/{{ custom_ds | ds }}_g.csv S3://URI',
    dag=dag,
)

# TODO: INIT
#   init staging
#   init main

# TODO: pip install apache-airflow-providers-amazon
# from airflow.providers.amazon.aws.transfers.s3_to_postgres import S3ToPostgresOperator

stage_game = S3ToPostgresOperator(
    task_id='stage_game',
    s3_source_key='path/to/your/csv_file.csv',
    postgres_target_table='your_target_table',
    postgres_preoperator="TRUNCATE your_target_table;",
    aws_conn_id='aws_default',
    postgres_conn_id='postgres_default',
    delimiter=',',
    ignore_headers=1,
    dag=dag,
)

load_game_table = PostgresOperator(
    task_id='load_casting_fact_table',
    postgres_conn_id="postgresdw",
    sql='path/to/sql',
    dag=dag
)

start_quality = EmptyOperator(task_id='start_quality',  dag=dag)

run_quality = DataQualityOperator(
    task_id='run_quality_title',
    pg_conn_id="postgresdw",
    table_name="title",
    dag=dag
)

end_operator = EmptyOperator(task_id='end_execution',  dag=dag)

####################
## Pipeline Order ##
####################

start_operator >> pull_game_data >> save_to_s3 >> stage_game >> load_game_table >> start_quality >> run_quality >> end_operator
