"""
LAMBDA FOR INGESTING A FILE FROM S3 to POSTGRES

- it first reads the file 1st row of a file 
and if its emptyit doesn't try the ingest

how to call the function
{
    "s3_bucket": "baskpipe",
    "s3_path": "data/daily_games",
    "file_name": "file.csv",
    "schema_name": "staging",
    "table_name": "st_daily_games",
    "copy_config": "(format csv,header true)",
    "aws_region": "eu-west-2"
}

"""

import json
import os
import sys

import boto3
from botocore.exceptions import ClientError

sys.path.append(os.path.join(os.path.dirname(__file__), "psycopg2-3.11"))
import psycopg2


# pylint: disable=duplicate-code
def get_db_credentials(secret_name):
    """Fetches database credentials from AWS Secrets Manager."""
    client = boto3.client("secretsmanager")

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret = get_secret_value_response["SecretString"]
        return json.loads(secret)
    except ClientError as e:
        raise ClientError("Error fetching DB credentials: ", e) from e


def any_data_in_file(bucket, key):
    """
    Reads the first two lines of a file on S3.
    A header row and the first line of data.
    If the first or second row have no data it concludes
    the file is empty and returns False else True.
    """

    s3 = boto3.client("s3")

    response = s3.get_object(Bucket=bucket, Key=key)

    # Read the content of the file
    streaming_body = response["Body"]

    # Read the contents line by line using iter_lines()
    line_count = 0
    for line in streaming_body.iter_lines():
        print("... reading line")
        decoded_line = line.decode("utf-8")
        if decoded_line.strip():
            line_count += 1

        if line_count == 2:
            break

    return line_count >= 2


def sql_s3_to_pg(sql_template_params: dict):
    """Executes the SQL query to ingest a file from S3 to Postgres."""
    db_credentials = get_db_credentials(os.getenv("DB_SECRET_NAME"))

    sql_template = """
        select aws_s3.table_import_from_s3(
        '{}.{}',
        '', 
        '{}',
        aws_commons.create_s3_uri(
                '{}',
                '{}',
                '{}'
            )
        );
    """

    sql_query = sql_template.format(
        sql_template_params["schema_name"],
        sql_template_params["table_name"],
        sql_template_params["copy_config"],
        sql_template_params["s3_bucket"],
        sql_template_params["full_s3_path"],
        sql_template_params["aws_region"],
    )

    try:
        with psycopg2.connect(
            host=db_credentials["host"],
            user=db_credentials["username"],
            password=db_credentials["password"],
            database=db_credentials["dbname"],
        ) as connection:
            with connection.cursor() as cursor:
                cursor.execute(sql_query)

                result = cursor.fetchall()
                response_text = (
                    f"SQL query executed successfully. Result set "
                    f"length: {len(result)}. "
                    f"Here are first 5 rows {result[:5]}"
                )

            connection.commit()

    except Exception as e:
        raise RuntimeError(f"Database query execution failed: {e}") from e

    return response_text


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """Executes a SQL to ingest a file from S3 t Postgres."""

    required_params = [
        "s3_bucket",
        "s3_path",
        "file_name",
        "schema_name",
        "table_name",
        "copy_config",
        "aws_region",
    ]

    missing_params = [
        param
        for param in required_params
        if param not in event or not event[param]
    ]

    if missing_params:
        raise ValueError(
            f"The following required parameters are "
            f"missing or empty: {', '.join(missing_params)}"
        )

    s3_bucket = event.get("s3_bucket")
    s3_path = event.get("s3_path")
    file_name = event.get("file_name")
    schema_name = event.get("schema_name")
    table_name = event.get("table_name")
    copy_config = event.get("copy_config")
    aws_region = event.get("aws_region")

    full_s3_path = os.path.join(s3_path, file_name)

    # any data in file
    if any_data_in_file(s3_bucket, full_s3_path):

        response_text = sql_s3_to_pg(
            {
                "schema_name": schema_name,
                "table_name": table_name,
                "copy_config": copy_config,
                "s3_bucket": s3_bucket,
                "full_s3_path": full_s3_path,
                "aws_region": aws_region,
            }
        )

    else:
        response_text = f"No data detected in {s3_bucket}/{full_s3_path}"
        print(response_text)

    # Return the result of the query
    return {"statusCode": 200, "body": response_text}
