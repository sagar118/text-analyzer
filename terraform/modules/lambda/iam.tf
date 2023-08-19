resource "aws_iam_role" "lambda_exec" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.lambda_exec.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

# Create an policy to allow the lambda to access the S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name = var.s3_access_policy_name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect : "Allow",
        Resource : var.s3_bucket_arns
      }
    ]
  })
}

# Attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_access_policy_attachment" {
  role = aws_iam_role.lambda_exec.id
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
