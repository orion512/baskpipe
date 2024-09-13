#!/bin/bash

# Check if lambda name is passed as argument
if [ -z "$1" ]; then
  echo "Usage: $0 <lambda-name> [aws-profile]"
  exit 1
fi

LAMBDA_NAME=$1
PROFILE=$2

# Navigate to the lambda function directory
cd "lambdas/$LAMBDA_NAME"

# Clean up any previous package directory
rm -rf src/package

# Install dependencies
pip install -r requirements.txt -t src/package/

# Copy everything from src into the package
cp -r src/* src/package/

# Package everything
cd src/package
zip -r ../../../$LAMBDA_NAME.zip .

# Upload to S3
if [ -z "$PROFILE" ]; then
  aws s3 cp ../../../$LAMBDA_NAME.zip s3://baskpipe/lambdas/$LAMBDA_NAME.zip
else
  aws s3 cp ../../../$LAMBDA_NAME.zip s3://baskpipe/lambdas/$LAMBDA_NAME.zip --profile=$PROFILE
fi

# Deploy to AWS Lambda using the S3 URL
if [ -z "$PROFILE" ]; then
  aws lambda update-function-code --function-name $LAMBDA_NAME --s3-bucket baskpipe --s3-key lambdas/$LAMBDA_NAME.zip
else
  aws lambda update-function-code --function-name $LAMBDA_NAME --s3-bucket baskpipe --s3-key lambdas/$LAMBDA_NAME.zip --profile=$PROFILE
fi

# Return to the src directory before cleaning up
cd ..

# Clean up deployment package
rm -rf package

# Clean up zip file
rm ../../$LAMBDA_NAME.zip

# Return to the project root
cd ../../

