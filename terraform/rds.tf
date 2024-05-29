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

# resource "aws_db_instance" "my_postgres_db" {
#   allocated_storage    = 20  // The size of the storage (in GB)
#   engine               = "postgres"
#   engine_version       = "16.1"  // Specify your desired version of PostgreSQL
#   instance_class       = "db.t3.micro"  // Choose the instance type
#   db_name              = "baskpipedb"  // The name of the database to create
#   username             = "baskpipebot"  // Username for the database administrator
#   password             = "C*1eZ4jtORvoQkqW"  // Password for the database administrator
#   parameter_group_name = "default.postgres16"  // Use the default parameter group
#   identifier           = "baskpipe-db"  // DB instance identifier

#   skip_final_snapshot  = true  // Set this to false if you want to create a final snapshot on deletion
#   publicly_accessible  = true  // Specifies if the DB instance is publicly accessible

#   vpc_security_group_ids = [aws_security_group.postgres_sg.id]
# }
