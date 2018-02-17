variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
}
variable "aws_region" {
  description = "AWS region."
}
variable "AWSACCESSKEY" {
    type = "string"
    description = "Read AWS access key from environment variable TF_VAR_AWSACCESSKEY"
}
variable "AWSSECRETKEY" {
    type = "string"
    description = "Read AWS secret key from environment variable TF_VAR_AWSSECRETKEY"
}