variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda invoke ARN"
}

variable "lambda_function_name" {
    type        = string
    description = "Lambda function name"
}

variable "env" {
    type        = string
    description = "Environment"
}

variable "api_name" {
    type        = string
    description = "API name"
}