#####################################################################
############## RDS - ROLEs ##########################################
#####################################################################

resource "aws_iam_role" "rds_s3_access_role" {
  name               = "rds-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "rds_s3_access_policy" {
  name        = "rds-s3-access-policy"
  description = "Policy for RDS to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.baskpipe_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_s3_access_attachment" {
  role       = aws_iam_role.rds_s3_access_role.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}

resource "aws_db_instance_role_association" "rds_role_assoc" {
  db_instance_identifier = "baskpipe-db"
  role_arn               = aws_iam_role.rds_s3_access_role.arn
  feature_name           = "s3Import"
  depends_on = [aws_db_instance.baskpipe_db]
}


#####################################################################
############## LAMBDA - ROLEs #######################################
#####################################################################

resource "aws_iam_role" "baskpipe_lambda_role" {
  name = "baskpipe-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.baskpipe_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.baskpipe_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.baskpipe_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "baskpipe_lambda_trigger_role" {
  name = "baskpipe-lambda-trigger-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "baskpipe_lambda_trigger_policy" {
  name = "baskpipe-lambda-trigger-policy"
  role = aws_iam_role.baskpipe_lambda_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "states:StartExecution"
        Resource = aws_sfn_state_machine.baskpipe_daily_games_baskref.arn
      }
    ]
  })
}


#####################################################################
############## STEP FUNCTION - BASKPIPE ROLE ########################
#####################################################################

resource "aws_iam_role" "baskpipe_stepf_role" {
  name = "baskpipe-stepf-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "baskpipe_stepf_policy" {
  name   = "baskpipe-stepf-policy"
  role   = aws_iam_role.baskpipe_stepf_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        Resource = "*"
      },
      {
        Effect: "Allow",
        Action: [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "${aws_lambda_function.baskpipe_daily_scrape.arn}",
          "${aws_lambda_function.sql_execute.arn}",
          "${aws_lambda_function.s3_to_postgres.arn}",
          "${aws_lambda_function.trigger_daily_scrape.arn}"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "sns:Publish"
        ],
        Resource = "${aws_sns_topic.sf_daily_baskref_notification.arn}"
      }
    ]
  })
}

#####################################################################
############## SNS - POLICY #########################################
#####################################################################

resource "aws_sns_topic_policy" "sns_publish_policy" {
  arn = aws_sns_topic.sf_daily_baskref_notification.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "TrustCWEToPublishEventsToMyTopic",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action   = "sns:Publish",
        Resource = aws_sns_topic.sf_daily_baskref_notification.arn
      }
    ]
  })
}

