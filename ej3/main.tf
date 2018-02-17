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

data "aws_availability_zones" "all" {}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
       create_before_destroy = true
   }
}

resource "aws_security_group" "elb" {
    name = "terraform-example-elb"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "example" {
    image_id = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
               #!/bin/bash
               echo "Hello, World" > index.html
               nohup busybox httpd -f -p "${var.server_port}" &
               EOF

   lifecycle {
       create_before_destroy = true
   }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]

    load_balancers = ["${aws_elb.example.name}"]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }

}

resource "aws_elb" "example" {
    name = "terraform-asg-example"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb.id}"]

    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:${var.server_port}/"
        interval            = 30
    }
}

output "elb_dns_name" {
   value = "${aws_elb.example.dns_name}"
}