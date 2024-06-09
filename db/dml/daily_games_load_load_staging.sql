select aws_s3.table_import_from_s3(
   'staging.st_daily_games',
   '', 
   '(format csv,header true)',
   aws_commons.create_s3_uri(
        'baskpipe',
		'daily_games/2024-06-06_games.csv',
	    'eu-west-2'
	)
);