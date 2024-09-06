# !/bin/bash

# Navigate to the lambda function directory
cd lambdas/s3-to-postgres

# Clean up any previous package directory
rm -rf src/package

# Install dependencies
pip install -r requirements.txt -t src/package/

# Copy the precompiled psycopg2-3.11 directory to the package directory
cp -r src/psycopg2-3.11/* src/package/

# Add your Lambda function code to the package
cp src/lambda_function.py src/package/

# Package everything
cd src/package
zip -r ../../../s3-to-postgres.zip .

# Upload to S3
aws s3 cp ../../../s3-to-postgres.zip s3://baskpipe/lambdas/s3-to-postgres.zip --profile=per-iac-man

# Deploy to AWS Lambda using the S3 URL
aws lambda update-function-code --function-name s3-to-postgres --s3-bucket baskpipe --s3-key lambdas/s3-to-postgres.zip --profile=per-iac-man

# Clean up deployment package
rm -rf src/package

# Clean up
rm ../../../s3-to-postgres.zip

# Return to the project root
cd ../../../
