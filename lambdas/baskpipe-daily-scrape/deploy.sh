# !/bin/bash

# Navigate to the lambda function directory
cd lambdas/baskpipe-daily-scrape

# Install dependencies
pip install -r requirements.txt -t src/package/

# Add your Lambda function code to the package
cp src/lambda_function.py src/package/

# Package everything
cd src/package
zip -r ../../../baskpipe-daily-scrape.zip .

# Upload to S3
aws s3 cp ../../../baskpipe-daily-scrape.zip s3://baskpipe/lambdas/baskpipe-daily-scrape.zip --profile=per-iac-man

# Deploy to AWS Lambda using the S3 URL
aws lambda update-function-code --function-name baskpipe-daily-scrape --s3-bucket baskpipe --s3-key lambdas/baskpipe-daily-scrape.zip --profile=per-iac-man

# Clean up deployment package
rm -rf src/package

# Clean up
rm ../../../baskpipe-daily-scrape.zip

# Return to the project root
cd ../../../
