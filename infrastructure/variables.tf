variable "aws_region" {
    description = "AWS region to create resources"
    default = "us-east-1"
}

variable "project_id" {
    description = "Project ID"
    default = "mlops-zc-ta"
}

variable "env" {
    description = "Execution Environment"
    type = string
}

variable "dataset_bucket_name" {
    description = "Dataset Bucket Name"
    type = string
}

variable "model_registry_bucket_name" {
    description = "Model Registry Bucket Name"
    type = string
}