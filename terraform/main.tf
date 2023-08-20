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
    name = "${var.org}-${var.project_name}-${var.env}-ec2-role"
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
    name = "${var.org}-${var.project_name}-${var.env}-ec2-instance-profile"
    role = aws_iam_role.ec2_role.name
}

# Create EC2 Instance and PostgreSQL RDS Instance
# Only create the EC2 Instance and RDS Instance if the environment is dev
# Otherwise, do not create the EC2 Instance and RDS Instance
# Connect the EC2 Instance to the RDS Instance
module "ec2_rds" {
    # count                   = "${var.env}" == "dev" ? 1 : 0
    source                  = "./modules/ec2_rds"
    db_name                 = "${var.db_name}_${var.env}"
    db_username             = var.db_username
    db_password             = var.db_password
    ec2_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name
    env                     = var.env
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
    s3_bucket_policy_name = "${var.org}-${var.project_name}-${var.env}-${var.dataset_bucket_name}-s3-policy"
    s3_bucket_arns = [
        module.dataset_bucket.s3_bucket_arn,
        "${module.dataset_bucket.s3_bucket_arn}/*"
    ]
    iam_role_name = aws_iam_role.ec2_role.name
}

# Create S3 Bucket Policy for Model Registry and Attach to EC2 Instance Role
module "model_registry_bucket_s3_ec2_policy" {
    source = "./modules/iam/s3"
    s3_bucket_policy_name = "${var.org}-${var.project_name}-${var.env}-${var.model_registry_bucket_name}-s3-policy"
    s3_bucket_arns = [
        module.model_registry_bucket.s3_bucket_arn,
        "${module.model_registry_bucket.s3_bucket_arn}/*"
    ]
    iam_role_name = aws_iam_role.ec2_role.name
}

module "ecr" {
    source = "./modules/ecr"
    ecr_repo_name = "${var.org}-${var.project_name}-${var.env}-ecr-repo"
    ec2_iam_role_name = aws_iam_role.ec2_role.name
    ecr_read_policy_name = "${var.org}-${var.project_name}-${var.env}-ecr-read-policy"
    ecr_write_policy_name = "${var.org}-${var.project_name}-${var.env}-ecr-write-policy"
}

module "lambda" {
    source                          = "./modules/lambda"
    lambda_role_name                = "${var.org}-${var.project_name}-${var.env}-lambda-role"
    lambda_function_name            = "${var.org}-${var.project_name}-${var.env}-lambda"
    lambda_s3_access_policy_name    = "${var.org}-${var.project_name}-${var.env}-lambda-s3-access-policy"
    lambda_logging_policy_name      = "${var.org}-${var.project_name}-${var.env}-lambda-logging-policy"
    image_uri                       = module.ecr.ecr_image_uri
    s3_bucket_arns                  = [
        module.model_registry_bucket.s3_bucket_arn,
        "${module.model_registry_bucket.s3_bucket_arn}/*"
    ]

}

module "api_gateway" {
    source                  = "./modules/api_gateway"
    api_name                = "${var.org}-${var.project_name}-${var.env}-api"
    lambda_invoke_arn       = module.lambda.lambda_invoke_arn
    lambda_function_name    = module.lambda.lambda_function_name
    env                     = var.env
}
