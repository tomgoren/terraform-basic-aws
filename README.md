# terraform-basic-aws
Create basic AWS infrastructure with Terraform

* Run with: `terraform [ plan | apply | destroy ] -var-file=VARIABLES_FILE.tfvars
* AMI generated by Packer: ami-a55595c8 (AZ: us-east-1) 
  - based on https://github.com/tomgoren/packer-ami-create.
* S3 bucket creation is managed by separate terraform configuration in `/s3`.
* Security group added to allow access only on 22 and 80.
* Credentials, region, AMI etc. are stored in .tfvars file outside
  of the repository.
* End result is an auto-scaled instance that pulls an nginx config from the S3 bucket
