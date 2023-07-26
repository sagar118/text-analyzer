resource "aws_iam_policy" "s3_bucket_policy" {
    name = var.s3_bucket_policy_name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                ]
                Effect = "Allow"
                Resource = var.s3_bucket_arns
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
    role        = var.iam_role_name
    policy_arn  = aws_iam_policy.s3_bucket_policy.arn
}