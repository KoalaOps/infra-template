resource "aws_ecr_repository" "image_repo" {
  name = var.image_repo_id
  image_scanning_configuration {
    scan_on_push = true
  }
}