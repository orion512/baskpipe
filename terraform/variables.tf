variable "baskpipe_db_password" {
  description = "The password for the RDS instance baskpipe"
  type        = string
  sensitive   = true
}

variable "notification_phone_number" {
  description = "The phone number for SNS SMS notifications in E.164 format."
  type        = string
}

variable "notification_email" {
  description = "The email address for SNS email notifications."
  type        = string
}
