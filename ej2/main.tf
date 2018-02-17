variable "AWSACCESSKEY" {
    type = "string"
    description = "Read AWS access key from environment variable TF_VAR_AWSACCESSKEY"
}
variable "AWSSECRETKEY" {
    type = "string"
    description = "Read AWS secret key from environment variable TF_VAR_AWSSECRETKEY"
}
variable "server_port" {
    type = "string"
    description = "The port the server will use for HTTP requests"
    default = 8080
}

provider "aws" {
   access_key = "${var.AWSACCESSKEY}"
   secret_key = "${var.AWSSECRETKEY}"
   region = "eu-west-3"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
   ami             = "${data.aws_ami.ubuntu.id}"
   instance_type   = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.instance.id}"]

   user_data = <<-EOF
               #!/bin/bash
               echo "Hello, World" > index.html
               nohup busybox httpd -f -p "${var.server_port}" &
               EOF

   tags {
       Name = "terraform-example"
   }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public-ip" {
   value = "${aws_instance.example.public_ip}"
}