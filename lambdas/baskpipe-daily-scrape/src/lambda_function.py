"""
Script for AWS Lambda to scrape NBA games for 1 day and save to S3.

Author: Dominik Zulovec Sajovic, April 2024

how to call the function

{
    "date": "2006-03-14",
    "s3_path": "s3://my-bucket/path/"
}

"""

import csv
import json
import os
from datetime import date, datetime
from io import StringIO

import boto3
from baskref.data_collection import BaskRefDataScraper, BaskRefUrlScraper


def scrape_games(date_of_games: date):
    """Runs baskref to get list of game for a specific date"""

    url_scraper = BaskRefUrlScraper()
    data_scraper = BaskRefDataScraper()

    game_urls = url_scraper.get_game_urls_day(date_of_games)
    print(f"Number of game URLs scraped: {len(game_urls)}")
    game_data = data_scraper.get_games_data(game_urls)
    print(f"Number of games scraped: {len(game_data)}")

    return game_data


def list_dicts_to_s3(data: list[dict], s3_path: str):
    """
    Writes a list of dictionaries to a CSV file and uploads it to S3.
    Writes an empty CSV with no columns if data is empty.

    Parameters:
    data (list of dict): The data to write to the CSV.
    Each dictionary in the list represents a row.
    s3_path (str): The full S3 path in the format
    's3://bucket-name/path/to/file.csv' where the CSV will be stored.

    Returns: None
    """

    if s3_path.startswith("s3://"):
        s3_path = s3_path[5:]
    bucket_name, key = s3_path.split("/", 1)

    s3 = boto3.client("s3")
    csv_buffer = StringIO()

    if len(data) > 0:
        fieldnames = data[0].keys()
        writer = csv.DictWriter(
            csv_buffer, fieldnames=fieldnames, quoting=csv.QUOTE_ALL
        )
        writer.writeheader()
        writer.writerows(data)

    csv_buffer.seek(0)

    s3.put_object(Bucket=bucket_name, Key=key, Body=csv_buffer.getvalue())


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """
    Processes games data by scraping and storing it in S3.

    Validates the presence and format of 'date' and 's3_path' in the event
    object. Scrapes games data for the given date and stores the results in S3.
    Logs errors and raises exceptions if any step fails.

    Parameters:
    event (dict): The Lambda event object containing:
        - 'date': The date for which to scrape games (str, YYYY-MM-DD).
        - 's3_path': The S3 bucket path where results should be stored (str).

    Returns:
    dict: A response object with a statusCode and a body indicating success.

    Raises:
    ValueError: If 'date' or 's3_path' are missing or if 'date' is not in the
    correct format. Exception: If an error occurs during the scraping
    or S3 writing process.
    """

    if "date" not in event:
        raise ValueError('Date variable is required ("date").')

    if "s3_path" not in event:
        raise ValueError('S3 path variable is required ("s3_path").')

    try:
        games_date = datetime.strptime(event["date"], "%Y-%m-%d").date()
    except ValueError as exc:
        raise ValueError("Date format must be YYYY-MM-DD.") from exc

    try:
        list_of_games = scrape_games(games_date)
    except Exception as err:
        print(err)
        raise RuntimeError("Something went wrong with the scraper.") from err

    try:
        full_s3_path = os.path.join(
            event["s3_path"], f"{event['date']}_games.csv"
        )
        list_dicts_to_s3(list_of_games, full_s3_path)
    except Exception as err:
        print(err)
        raise RuntimeError(
            "Something went wrong with writing data to S3.") from err

    return {
        "statusCode": 200,
        "body": json.dumps("Operation completed successfully"),
    }
