variable "aws_region" {
  default = "eu-west-1"
}

variable "db_username" {
  default   = "admin"
  sensitive = true
}

variable "db_password" {
  default   = "admin123"
  sensitive = true
}
