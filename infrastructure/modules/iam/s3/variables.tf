variable "s3_bucket_policy_name" {
    description = "Name of S3 Bucket Policy"
    type        = string
}

variable "s3_bucket_arns" {
    description = "ARN of S3 Bucket"
    type        = list(string)
}

variable "iam_role_name" {
    description = "Name of IAM Role"
    type        = string
}