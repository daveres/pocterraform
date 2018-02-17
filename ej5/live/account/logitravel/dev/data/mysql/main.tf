# terraform {
#   required_version = ">= 0.11, < 0.12"
#   backend "gcs" {
#     credentials = "terraform-credentials.json"
#     bucket  = "bk-tf-state-prod"
#     prefix  = "terraform/state/live/account/logitravel/dev/data/mysql"
#   }
# }

provider "aws" {
  version = "~> 1.9"
  access_key = "${var.AWSACCESSKEY}"
  secret_key = "${var.AWSSECRETKEY}"
  region = "${var.aws_region}"
}

resource "aws_db_instance" "example" {
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "example_database"
  username            = "admin"
  password            = "${var.db_password}"
  skip_final_snapshot = true
}