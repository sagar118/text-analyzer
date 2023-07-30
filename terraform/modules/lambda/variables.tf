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