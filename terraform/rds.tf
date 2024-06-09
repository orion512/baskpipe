resource "aws_security_group" "postgres_sg" {
  name = "postgres_sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Adjust this to your IP ranges for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_db_instance" "baskpipedb" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.micro"
  storage_type         = "gp2"
  db_name              = "baskpipedb"
  username             = "baskpipebot"
  password             = var.baskpipe_db_password
  parameter_group_name = "default.postgres16"
  identifier           = "baskpipe-db"
  

  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
}

resource "aws_iam_policy" "rds_s3_access_policy" {
  name        = "rds-s3-access-policy"
  description = "Policy for RDS to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::baskpipe/*"
      }
    ]
  })
}

resource "aws_iam_role" "rds_s3_access_role" {
  name               = "rds-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_s3_access_attachment" {
  role       = aws_iam_role.rds_s3_access_role.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}

resource "aws_db_instance_role_association" "rds_role_assoc" {
  db_instance_identifier = "baskpipe-db"
  role_arn               = aws_iam_role.rds_s3_access_role.arn
  feature_name           = "s3Import"
}