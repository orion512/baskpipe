# !/bin/bash

# Navigate to the lambda function directory
cd lambdas/trigger-daily-scrape

# Clean up any previous package directory
rm -rf src/package

# Install dependencies
pip install -r requirements.txt -t src/package/

# Add your Lambda function code to the package
cp src/lambda_function.py src/package/

# Package everything
cd src/package
zip -r ../../../trigger-daily-scrape.zip .

# Upload to S3
aws s3 cp ../../../trigger-daily-scrape.zip s3://baskpipe/lambdas/trigger-daily-scrape.zip --profile=per-iac-man

# Deploy to AWS Lambda using the S3 URL
aws lambda update-function-code --function-name trigger-daily-scrape --s3-bucket baskpipe --s3-key lambdas/trigger-daily-scrape.zip --profile=per-iac-man

# Clean up deployment package
rm -rf src/package

# Clean up
rm ../../../trigger-daily-scrape.zip

# Return to the project root
cd ../../../
