variable "AWSACCESSKEY" {
    type = "string"
    description = "Read AWS access key from environment variable TF_VAR_AWSACCESSKEY"
}
variable "AWSSECRETKEY" {
    type = "string"
    description = "Read AWS secret key from environment variable TF_VAR_AWSSECRETKEY"
}
variable "aws_region" {
  description = "AWS region."
}
variable "db_password" {
  description = "The password for the database"
}