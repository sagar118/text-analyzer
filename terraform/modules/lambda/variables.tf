variable "lambda_role_name" {
    type        = string
    description = "Lambda role name"
}

variable "lambda_function_name" {
    type        = string
    description = "Lambda function name"
}

variable "image_uri" {
    type        = string
    description = "ECR image URI"
}

variable "s3_bucket_arns" {
    type        = list(string)
    description = "List of S3 bucket ARNs"
}

variable "lambda_s3_access_policy_name" {
    type        = string
    description = "Lambda S3 access policy name"
}