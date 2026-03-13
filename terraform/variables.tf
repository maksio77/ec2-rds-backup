variable "aws_region" {
  default = "eu-west-1"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "pgadmin_passwd" {
  type      = string
  sensitive = true
}
