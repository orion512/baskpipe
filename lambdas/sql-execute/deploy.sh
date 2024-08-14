# !/bin/bash

# Navigate to the lambda function directory
cd lambdas/sql-execute

# Install dependencies
pip install -r requirements.txt -t src/package/

# Add your Lambda function code to the package
cp src/lambda_function.py src/package/

# Package everything
cd src/package
zip -r ../../../sql-execute.zip .

# Upload to S3
aws s3 cp ../../../sql-execute.zip s3://baskpipe/lambdas/sql-execute.zip --profile=per-iac-man

# Deploy to AWS Lambda using the S3 URL
aws lambda update-function-code --function-name sql-execute --s3-bucket baskpipe --s3-key lambdas/sql-execute.zip --profile=per-iac-man

# Clean up deployment package
rm -rf src/package

# Clean up
rm ../../../sql-execute.zip

# Return to the project root
cd ../../../
