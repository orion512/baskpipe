select aws_s3.table_import_from_s3(
   '{SCHEMA_NAME}.{TABLE_NAME}',
   '', 
   '(format csv,header true)',
   aws_commons.create_s3_uri(
        '{BUCKET_NAME}',
		'{S3_PATH}',
	    '{REGION_NAME}'
	)
);