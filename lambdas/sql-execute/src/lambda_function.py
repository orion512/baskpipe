"""
LAMBDA FOR SQL EXECUTION

how to call the function

{
    "s3_sql_path": "s3://my-bucket/path/to/sql_file.sql",
    "custom_params": {"TABLE_NAME": "my_table"}
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
        raise RuntimeError("Error fetching DB credentials: ", e) from e


def fetch_sql_from_s3(s3_path):
    """Fetches SQL query from a file stored in S3."""
    s3 = boto3.client("s3")
    bucket_name, key = s3_path.replace("s3://", "").split("/", 1)

    try:
        response = s3.get_object(Bucket=bucket_name, Key=key)
        sql_query = response["Body"].read().decode("utf-8")
        return sql_query
    except ClientError as e:
        raise RuntimeError("Error fetching SQL from S3: ", e) from e


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """Executes a SQL query on the PostgreSQL database."""
    if "sql_query" not in event and "s3_sql_path" not in event:
        raise ValueError('Event must contain "sql_query" or "s3_sql_path".')

    sql_query = event.get("sql_query")
    s3_sql_path = event.get("s3_sql_path")
    custom_params = event.get("custom_params", {})

    # Fetch SQL from S3 if s3_sql_path is provided
    if s3_sql_path:
        sql_query = fetch_sql_from_s3(s3_sql_path)

    # Safely insert custom parameters like table names
    sql_query = sql_query.format(**custom_params)

    # Fetch database credentials
    db_credentials = get_db_credentials(os.getenv("DB_SECRET_NAME"))

    try:
        # Establish a database connection using a context manager
        with psycopg2.connect(
            host=db_credentials["host"],
            user=db_credentials["username"],
            password=db_credentials["password"],
            database=db_credentials["dbname"],
        ) as connection:
            with connection.cursor() as cursor:
                # Execute the SQL query
                cursor.execute(sql_query)

                # Check if it's a SELECT query
                if cursor.description is not None:
                    result = cursor.fetchall()  # Fetch all results
                    response_text = (
                        f"SQL query executed successfully. "
                        f"Result set length: {len(result)}. "
                        f"Here are first 5 rows {result[:5]}"
                    )
                else:
                    response_text = (
                        "SQL query executed successfully. "
                        "No result set returned. "
                        "Query was probably a DDL/DML operation."
                    )

            connection.commit()

    except Exception as e:
        raise RuntimeError(f"Database query execution failed: {e}") from e

    print(response_text)

    # Return the result of the query
    return {"statusCode": 200, "body": response_text}
