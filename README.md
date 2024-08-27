# Baskpipe (Basketball Data Pipeline)
A fully AWS native data pipeline.

# What does it do?


# How to use it?




# Terraform

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

# Folder Structure

# DB - SQL
Upload all SQLs to S3 to be used by AWS services.
```
aws s3 cp ./db s3://baskpipe/sqls/ --recursive --profile per-iac-man
```

In the future potentially create a GH action whcih moves ./db folder to S3 on push to main.

