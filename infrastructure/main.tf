# Backend Key:
# dev: infrastructure-dev.tfstate
# stg: infrastructure-stg.tfstate
# prod: infrastructure-prod.tfstate

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.8.0"
        }
    }

    cloud {
        organization = "mlops-zoomcamp"
        workspaces {
            tags = ["text-analyzer", "aws"]
        }
    }

    required_version = ">= 1.5.3"
}

provider "aws" {
    region = var.aws_region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

# Create an IAM Role
resource "aws_iam_role" "ec2_role" {
    name = "${var.org}-${var.project_name}-ec2-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "${var.org}-${var.project_name}-ec2-instance-profile"
    role = aws_iam_role.ec2_role.name
}

# Create an EC2 Instance
module "mlops_zc_ta_ec2_instance" {
    count                   = "${var.env}" == "dev" ? 1 : 0
    source                  = "./modules/ec2"
    ami                     = "ami-053b0d53c279acc90"
    instance_type           = "t3.2xlarge"
    key_name                = "mlops-zc-key"
    name                    = "${var.org}-${var.project_name}-ec2"
    env                     = "${var.env}"
    iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name
}

# Create a S3 Bucket for Dataset
module "dataset_bucket" {
    source = "./modules/s3"
    bucket_name = "${var.org}-${var.project_name}-${var.env}-${var.dataset_bucket_name}"
    bucket_env = "${var.env}"
}

# Create a S3 Bucket for Model Registry 
module "model_registry_bucket" {
    source = "./modules/s3"
    bucket_name = "${var.org}-${var.project_name}-${var.env}-${var.model_registry_bucket_name}"
    bucket_env = "${var.env}"
}

# Create S3 Bucket Policy for Dataset and Attach to EC2 Instance Role
module "dataset_bucket_s3_ec2_policy" {
    source = "./modules/iam/s3"
    s3_bucket_policy_name = "${var.org}-${var.project_name}-${var.dataset_bucket_name}-s3-policy"
    s3_bucket_arns = [
        module.dataset_bucket.s3_bucket_arn,
        "${module.dataset_bucket.s3_bucket_arn}/*"
    ]
    iam_role_name = aws_iam_role.ec2_role.name
}

# Create S3 Bucket Policy for Model Registry and Attach to EC2 Instance Role
module "model_registry_bucket_s3_ec2_policy" {
    source = "./modules/iam/s3"
    s3_bucket_policy_name = "${var.org}-${var.project_name}-${var.model_registry_bucket_name}-s3-policy"
    s3_bucket_arns = [
        module.model_registry_bucket.s3_bucket_arn,
        "${module.model_registry_bucket.s3_bucket_arn}/*"
    ]
    iam_role_name = aws_iam_role.ec2_role.name
}

