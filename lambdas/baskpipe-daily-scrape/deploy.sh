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

# Deploy to AWS Lambda
aws lambda update-function-code --function-name baskpipe-daily-scrape --zip-file fileb://../../../baskpipe-daily-scrape.zip --profile=per-iac-man

# Clean up
rm ../../../baskpipe-daily-scrape.zip

# Return to the project root
cd ../../../
