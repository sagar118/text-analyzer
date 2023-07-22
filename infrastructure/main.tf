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

    backend "s3" {
        bucket  = "tf-state-mlops-zc"
        region  = "us-east-1"
        encrypt = true
    }

    required_version = ">= 1.5.0"
}

provider "aws" {
    region = var.aws_region
}

data "aws_caller_identity" "current_identity" {}

locals {
    # Get the AWS account ID to create ARNs for resources
    account_id = data.aws_caller_identity.current_identity.account_id
}

module "mlops_zc_ta_ec2_instance" {
    count           = "${var.env}" == "dev" ? 1 : 0
    source          = "./modules/ec2"
    ami             = "ami-053b0d53c279acc90"
    instance_type   = "t3.2xlarge"
    key_name        = "mlops-zc-key"
    name            = "mlops-zc-ta-ec2"
}

module "dataset_bucket" {
    source = "./modules/s3"
    bucket_name = "${var.project_id}-${var.env}-${var.dataset_bucket_name}"
    bucket_env = "${var.env}"
}

module "model_registry_bucket" {
    source = "./modules/s3"
    bucket_name = "${var.project_id}-${var.env}-${var.model_registry_bucket_name}"
    bucket_env = "${var.env}"
}