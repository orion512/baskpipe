# Baskpipe (Basketball Data Pipeline)

Fully AWS native data pipelines for processing basketball (NBA) data.

# Setup

The entire AWS infrastrucutre is controlled by Terraform.

## Infrastructure on AWS with Terraform

- setup credentials
- setup variables
- run terraform (it will fail)
- upload lambdas
- run terraform again
- upload db
- run initdb pipeline

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

Create a file called main.tf (copy template from main.tf.example).

In order to use, you need to navigate into the terraform folder.
```
cd terraform
```

It controls the AWS infrastructure.
- creates
- updates
- destroys

```
terraform init

terraform plan

terraform apply
```

Create a file terraform.tvars (which is gitignored).
In the file define your DB password.
```
baskpipe_db_password = "YOUR_PASSWORD"
```

## Sync code change with Terraform
There are two pieces of code that need to be synced with AWS:
- contents of DB folder needs to be uploaded to S3
- every lambda function needs to be built, zipped, uploaded to S3 and update the lambda

### GitHub Actions
First you need to add AWS Credentials to GitHub Secrets:
- Go to your GitHub repository.
- Click on "Settings" → "Secrets and variables" → "Actions".
- Click on "New repository secret".
- Add the following secrets:
    - Name: AWS_ACCESS_KEY_ID, Value: your AWS access key.
    - Name: AWS_SECRET_ACCESS_KEY, Value: your AWS secret access key.
    - Name: AWS_REGION, Value: your AWS region.

### Manual
Sync all SQLs to S3 to be used by AWS services.
```
aws s3 sync ./db s3://baskpipe/sqls/ --delete --profile per-iac-man
```

Deploy a lambda
```
./lambdas/deploy.sh LAMBDA_NAME OPTIONAL_PROFILE
./lambdas/deploy.sh s3-to-postgres per-iac-man
```

chmod +x ./lambdas/deploy.sh

### Code Formatting
black .
pylint --recursive=y ./

is there a way to not allow to commit if not installed
pre-commit install


Push seasons data to S3
```
aws s3 sync ./datasets s3://baskpipe/data/season_games/ --delete --profile per-iac-man
```