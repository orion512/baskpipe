resource "aws_s3_bucket" "baskpipe_bucket" {
  bucket = "baskpipe"
}

# root level folders
resource "aws_s3_object" "data_folder" {
  bucket = aws_s3_bucket.baskpipe_bucket.bucket
  key    = "data/"
}

resource "aws_s3_object" "lambdas_folder" {
  bucket = aws_s3_bucket.baskpipe_bucket.bucket
  key    = "lambdas/"
}

resource "aws_s3_object" "sqls_folder" {
  bucket = aws_s3_bucket.baskpipe_bucket.bucket
  key    = "sqls/"
}

# data subfolders
resource "aws_s3_object" "daily_games_folder" {
  bucket = aws_s3_bucket.baskpipe_bucket.bucket
  key    = "data/daily_games/"
}

resource "aws_s3_object" "season_games_folder" {
  bucket = aws_s3_bucket.baskpipe_bucket.bucket
  key    = "data/season_games/"
}
