# Terraform configuration for basic infrastucture setup
#
# Create Auto-Scaling Group based on AMI built by Packer
# Implement rudimentary network security hardening by limiting access
#


variable "aws" {
    # data stored in tfvars file
    default = {}
}

# AWS
provider "aws" {
    # AWS credentials and regsion specified in variables file
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
    }

    ingress {
        # Allow access only for HTTP
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
}

# Launch Configuration
# Create multiple identical instances for autoscale
resource "aws_launch_configuration" "basic_instance" {
  name = "basic_appserver"
  image_id = "${var.aws.ami_id}"
  instance_type = "m3.medium"
  security_groups = ["${aws_security_group.basic_sg1.id}"]
}

# Autoscaling Group
resource "aws_autoscaling_group" "basic-asg" {
  min_size = 1
  max_size = 3
  launch_configuration = "${aws_launch_configuration.basic_instance.name}"
}


# S3 bucket
# Here is where we store configuration files that will be deployed to the instance(s)
resource "aws_s3_bucket" "basic_bucket" {
    bucket = "terraform_basic_bucket"
    acl = "private"
}
