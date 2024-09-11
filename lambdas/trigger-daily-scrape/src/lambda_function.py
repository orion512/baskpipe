"""
LAMBDA FOR TRIGERRING A STEP FUNCTION FOR DAILY BASKPIPE

- it's trick is that it calculates yesterday's date

how to call the function
{ }

"""

import os
import json
from datetime import datetime, timedelta
import boto3


def lambda_handler(event, context):
    """ Calculated yesterday's date and triggers AWS step."""
    
    # Calculate yesterday's date
    yesterday = datetime.utcnow() - timedelta(days=1)
    date_day = yesterday.strftime('%Y-%m-%d')
    
    # Step Function input
    input_data = {"date_day": date_day}

    # Get the Step Function ARN from the environment variable
    state_machine_arn = os.getenv('STEP_FUNCTION_ARN')
    
    # Start Step Function
    client = boto3.client('stepfunctions')
    
    response = client.start_execution(
        stateMachineArn=state_machine_arn,
        input=json.dumps(input_data)
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(response, default=str)
    }
