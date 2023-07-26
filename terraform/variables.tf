variable "aws_region" {
    description = "AWS region to create resources"
    default = "us-east-1"
}

variable "org" {
    description = "Project Organization"
    default = "mlops-zc"
}

variable "project_name" {
    description = "Project Name"
    default = "ta"
}

variable "env" {
    description = "Project Environment"
}

variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "db_name" {
    description = "Database name"
    type        = string 
}

variable "db_username" {
    description = "Database username"
    type        = string
    sensitive   = true
}

variable "db_password" {
    description = "Database password"
    type        = string
    sensitive   = true
}

variable "dataset_bucket_name" {
    description = "Name of S3 Bucket for Dataset"
    default = "dataset"
}

variable "model_registry_bucket_name" {
    description = "Name of S3 Bucket for Model Registry"
    default = "model-registry"
}