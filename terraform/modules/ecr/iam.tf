resource "aws_iam_policy" "ecr_read_policy" {
  name = var.ecr_read_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        Effect   = "Allow",
        Resource = aws_ecr_repository.ecr_repo.arn
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_write_policy" {
  name = var.ecr_write_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Effect   = "Allow",
        Resource = aws_ecr_repository.ecr_repo.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecr_read_attachment" {
  name       = "ECRReadAttachment"
  policy_arn = aws_iam_policy.ecr_read_policy.arn
  role       = vars.ec2_iam_role_name
}

resource "aws_iam_policy_attachment" "ecr_write_attachment" {
  name       = "ECRWriteAttachment"
  policy_arn = aws_iam_policy.ecr_write_policy.arn
  role       = vars.ec2_iam_role_name
}
