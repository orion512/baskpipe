/**

nba_daily_games_baskref

get_data_scrape -------------

{
  "date.$": "$.date_day",
  "s3_path": "s3://baskpipe/data/daily_games/"
}

OUTPUT WITH RESULTPATH
$.combinedResult

need CLOUDWATCH LOGS
need execution role

load_staging

{
  "s3_sql_path": "s3://baskpipe/sqls/dml/universal_s3_csv_load.sql",
  "custom_params": {
    "SCHEMA_NAME": "staging",
    "TABLE_NAME": "st_daily_games",
    "BUCKET_NAME": "baskpipe",
    "S3_PATH.$": "States.Format('data/daily_games/{}_games.csv', $.date_day)",
    "REGION_NAME": "eu-west-2"
  },
  "secret_name": "baskpipe_db_secret"
}

*/


resource "aws_sfn_state_machine" "nba_daily_games_baskref" {
  name     = "nba-daily-games-baskref"
  role_arn = aws_iam_role.stepf_nba_daily_games_baskref_role.arn

  definition = <<EOF
  {
    "Comment": "This is a pipeline for fetching, storing and procesing daily nba games.",
    "StartAt": "get_data_scrape",
    "States": {
      "get_data_scrape": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.baskpipe-daily-scrape.arn}",
        "ResultPath": "$.combinedResult",
        "Parameters": {
            "date.$": "$.date_day",
            "s3_path": "s3://baskpipe/data/daily_games/"
        },
        "Next": "init_staging"
      },
      "init_staging": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.sql-execute.arn}",
        "ResultPath": "$.combinedResult",
        "Parameters": {
          "s3_sql_path": "s3://baskpipe/sqls/ddl/st_daily_games.sql",
          "custom_params": {},
          "secret_name": "baskpipe_db_secret"
        },
        "Next": "load_staging"
      },
      "load_staging": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.sql-execute.arn}",
        "ResultPath": "$.combinedResult",
        "Parameters": {
          "s3_sql_path": "s3://baskpipe/sqls/dml/universal_s3_csv_load.sql",
          "custom_params": {
            "SCHEMA_NAME": "staging",
            "TABLE_NAME": "st_daily_games",
            "BUCKET_NAME": "baskpipe",
            "S3_PATH.$": "States.Format('data/daily_games/{}_games.csv', $.date_day)",
            "REGION_NAME": "eu-west-2"
          },
          "secret_name": "baskpipe_db_secret"
        },
        "Next": "init_public"
      },
      "init_public": {
        "Type": "Parallel",
        "Branches": [
          {
            "StartAt": "init_games",
            "States": {
              "init_games": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.sql-execute.arn}",
                "ResultPath": "$.combinedResult",
                "Parameters": {
                  "s3_sql_path": "s3://baskpipe/sqls/ddl/games.sql",
                  "custom_params": {},
                  "secret_name": "baskpipe_db_secret"
                },
                "End": true
              }
            }
          },
          {
            "StartAt": "init_teams",
            "States": {
              "init_teams": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.sql-execute.arn}",
                "ResultPath": "$.combinedResult",
                "Parameters": {
                  "s3_sql_path": "s3://baskpipe/sqls/ddl/teams.sql",
                  "custom_params": {},
                  "secret_name": "baskpipe_db_secret"
                },
                "End": true
              }
            }
          }
        ],
        "End": true
      }
    }
  }
  EOF
}
