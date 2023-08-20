output "ecr_repo" {
  value = "${var.org}-${var.project_name}-${var.env}-ecr-repo"
}

output "lambda_function" {
  value = "${var.org}-${var.project_name}-${var.env}-lambda"
}

output "model_registry_model_bucket" {
  value = "${var.org}-${var.project_name}-${var.env}-${var.model_registry_bucket_name}"
}

# echo "::set-output name=ecr_repo::$(terraform output ecr_repo | xargs)"
#           echo "::set-output name=predictions_stream_name::$(terraform output predictions_stream_name | xargs)"
#           echo "::set-output name=model_bucket::$(terraform output model_bucket | xargs)"
#           echo "::set-output name=lambda_function::$(terraform output lambda_function | xargs)"
