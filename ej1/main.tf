variable "AWSACCESSKEY" {
    type = "string"
    description = "Read AWS access key from environment variable TF_VAR_AWSACCESSKEY"
}
variable "AWSSECRETKEY" {
    type = "string"
    description = "Read AWS secret key from environment variable TF_VAR_AWSSECRETKEY"
}

provider "aws" {
   access_key = "${var.AWSACCESSKEY}"
   secret_key = "${var.AWSSECRETKEY}"
   region = "eu-west-3"
}

resource "aws_instance" "example" {
   ami             = "ami-c1cf79bc"
   instance_type   = "t2.micro"
}