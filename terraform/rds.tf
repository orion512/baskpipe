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



resource "aws_db_instance" "baskpipe_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.3"
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
