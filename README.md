# Baskpipe (Basketball Data Pipeline)

Fully AWS-native data pipelines for processing basketball (NBA) data.

## Setup

The entire AWS infrastructure is managed with Terraform. Follow the steps below to set it up from scratch.

### Enter AWS Details

- Create a `main.tf` file (copy the template from `main.tf.example`). Fill it with your AWS credentials.
- Create a `terraform.tvars` file (copy the template from `terraform.tvars.example`). Fill it with your AWS details (e.g., DB password, region).

Both files are gitignored.

### Run Terraform

Once the files are set up, you can run Terraform. Navigate to the `terraform` folder:
```
cd terraform
```

Initialize the state and plan, which should result in creating many new resources (~40 as of Sep 22nd, 2024):

```
terraform init
terraform plan
```

Then apply the changes:

```
terraform apply
```
Enter 'yes' when prompted.

It will run for a while, adding many resources, but eventually, it will fail due to missing S3 paths for the Lambdas. The automation for this is not fully set up yet, so a workaround is needed.

### Workaround to upload lambdas

This step is only required during the initial project setup. The CI/CD pipeline for Lambdas is automated for future updates. Normally, the `lambdas/deploy.sh` script is used to package, upload, and register the new Lambdas, but it requires the Lambdas to already exist in your AWS account.

To resolve this, open `lambdas/deploy.sh` and comment out the following code:
```
# Upload to S3
if [ -z "$PROFILE" ]; then
  aws s3 cp ../../../$LAMBDA_NAME.zip s3://baskpipe/lambdas/$LAMBDA_NAME.zip
else
  aws s3 cp ../../../$LAMBDA_NAME.zip s3://baskpipe/lambdas/$LAMBDA_NAME.zip --profile=$PROFILE
fi
```
With that commented out, you can now package and upload the Lambdas to S3. Run the script as follows:
```
./lambdas/deploy.sh LAMBDA_NAME OPTIONAL_PROFILE
```
If you encounter any permission issues, run:
```
chmod +x ./lambdas/deploy.sh
```

To upload the 4 lambdas, run:
```
./lambdas/deploy.sh baskpipe-daily-scrape
./lambdas/deploy.sh s3-to-postgres
./lambdas/deploy.sh sql-execute
./lambdas/deploy.sh trigger-daily-scrape
```

**Don't forget to uncomment the commented-out block afterward!**

### Back to Running Terraform

Now, you can rerun:
```
terraform plan
terraform apply
```
This should work and create the remaining resources. If you run into any issues, feel free to reach out for help.

### Upload the queries needed for pipelines to work
Next, upload the database code (SQLs) to S3. This is typically handled via GitHub Actions, but for the first setup, it needs to be done manually:
```
aws s3 sync ./db s3://baskpipe/sqls/ --delete
```

he above process should have created the following AWS resources:
- RDS DB
- Step Functions
- Lambdas
- S3 bucket
- EventBridge rules
- SNS topics
- ... maybe others

You are now all set to start running pipelines.

## Running the Pipelines

### Initialize the Database
Go to the AWS console (or use the AWS CLI), navigate to Step Functions, select ``baskpipe-initdb``, and click "Start Execution". This pipeline will initialize your RDS database by creating the required Postgres extensions and tables needed to store data.

### Backfill the Data
The ``baskpipe-season-games-backfill`` Step Function can be run with the following initial state:
```
{
  "years": [
    2000,
    2001,
    ...
    2023,
    2024
  ]
}
```

It expects CSV files for entire seasons to be available on S3 at ``s3://baskpipe/data/season_games/``. These files are not included in this repository but can be scraped using this scraper https://github.com/orion512/baskref.

```
# example command for scraping all games from 2024
baskref -t gs -y 2023 -fp datasets
```
Once scraped you can upload them all to S3 with
```
aws s3 sync ./datasets s3://baskpipe/data/season_games/ --delete
```
If you need historical CSVs, I have files dating back to 2000 — let me know if you'd like them.

## Development and CI/CD

### Prepare dev environment
Create a new virtual environemnt
```
python -m venv venv
source venv/bin/activate
```
Install all the dev requirements
```
pip install -r requirements_dev.txt

# uninstall all packages linux
pip freeze | xargs pip uninstall -y
```
Install the pre-commit hook
```
pre-commit install
```
On commit the hook will automatically run black, isort and pylint.
```
black .
pylint --recursive=y ./
isort .
```

### GitHub Actions
First you need to add AWS Credentials to GitHub Secrets:
- Go to your GitHub repository.
- Click on "Settings" → "Secrets and variables" → "Actions".
- Click on "New repository secret".
- Add the following secrets:
    - Name: AWS_ACCESS_KEY_ID, Value: your AWS access key.
    - Name: AWS_SECRET_ACCESS_KEY, Value: your AWS secret access key.
    - Name: AWS_REGION, Value: your AWS region.

There are 3 Actions wcich will run on any newly pushed code:
- linting
- If linting is successful, the files in the ``/db`` folder will be uploaded to S3.
- If linting is successful, all Lambdas will be deployed.

## Contributors

1. [Dominik Zulovec Sajovic](https://www.linkedin.com/in/dominik-zulovec-sajovic/)
