terraform {
  required_version = ">= 0.11, < 0.12"
}
provider "aws" {
  version = "~> 1.9"
  access_key = "${var.AWSACCESSKEY}"
  secret_key = "${var.AWSSECRETKEY}"
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "terraform_poc" {
  bucket = "${var.bucket_name}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}