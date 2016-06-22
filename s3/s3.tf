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

# S3 bucket
# Here is where we store configuration files that will be deployed to the instance(s)
resource "aws_s3_bucket" "basic_bucket" {
    # The challenge called for a bucket named 'config' but the AWS
    # shared namespace made that impossible.
    bucket = "challenge_config"
    acl = "public-read"
    policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::challenge_config/*"]
    }
  ]
}
EOF
}


