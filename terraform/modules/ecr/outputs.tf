output "ecr_image_uri" {
  value     = "${aws_ecr_repository.ecr_repo.repository_url}:${var.ecr_image_tag}"
}