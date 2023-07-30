resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"

  # Placeholder image URI, you can replace this with any valid URI
  image_uri     = var.image_uri

  tracing_config {
    mode = "Active"
  }

  timeout = 180
}
