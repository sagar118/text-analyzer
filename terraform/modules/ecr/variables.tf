variable "ecr_repo_name" {
    type        = string
    description = "ECR repo name"
}

variable "ecr_image_tag" {
    type        = string
    description = "ECR repo name"
    default = "latest"
}

variable "ec2_iam_role_name" {
    type        = string
    description = "EC2 IAM role name"
}

variable "ecr_read_policy_name" {
    type        = string
    description = "ECR read policy name"
}

variable "ecr_write_policy_name" {
    type        = string
    description = "ECR write policy name"
}
