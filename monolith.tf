# Terraform configuration for basic infrastucture setup
#
# Create Auto-Scaling Group based on AMI built by Packer
# Implement rudimentary network security hardening by limiting access
#
# This file could be broken up into multiple '.tf' files.
# I chose not to for simplicity's sake, but anything of larger scale
# I would use separate files, i.e.: 'security_group.tf, auto-scaling.tf, etc.'


variable "aws" {
    # data stored in tfvars file
    default = {}
}

# AWS
provider "aws" {
    # AWS credentials and region specified in variables file
    access_key = "${var.aws.access_key}"
    secret_key = "${var.aws.secret_key}"
    region = "${var.aws.region}"
}

# Security Group
resource "aws_security_group" "basic_sg1" {
    # Security group to limit access to instances
    name = "basic_sg1"
    description = "Deny all, allow only ssh and HTTP"
    
    ingress {
        # Allow access only for SSH
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        # Allow access only for HTTP
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Launch Configuration
# Create multiple identical instances for autoscale
resource "aws_launch_configuration" "basic_instance" {
    name = "basic_appserver"
    image_id = "${var.aws.ami_id}"
    instance_type = "m3.medium"
    security_groups = ["${aws_security_group.basic_sg1.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.s3_readonly.name}"
    key_name = "${aws_key_pair.ubuntu.key_name}"
    # This causes weird issues on occasion because of an AWS bug
    # At least according to https://github.com/hashicorp/terraform/issues/7198
    # When it works it works
    user_data = "${file("cloud-init.sh")}"
    lifecycle {
        create_before_destroy = true
    }
}

# Autoscaling Group
resource "aws_autoscaling_group" "basic-asg" {
    min_size = 1
    max_size = 3
    launch_configuration = "${aws_launch_configuration.basic_instance.name}"
    availability_zones = ["${var.aws.availability_zone}"]
}

# IAM permissions
# Should allow EC2 instances to access S3 buckets
# Might be redundant with S3 bucket permissions set to public

# This is the part that ties the role and the policy together for the launch configuration
resource "aws_iam_instance_profile" "s3_readonly" {
  name  = "s3-readonly"
  roles = ["${aws_iam_role.get_configs_role.name}"]
}

resource "aws_iam_role_policy" "get_configs_policy" {
    name = "get_configs_policy"
    role = "${aws_iam_role.get_configs_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "get_configs_role" {
    name = "get_configs_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# SSH key for instances
resource "aws_key_pair" "ubuntu" {
    key_name = "ubuntu_key"
    public_key = "${var.aws.ssh_public_key}"
}
