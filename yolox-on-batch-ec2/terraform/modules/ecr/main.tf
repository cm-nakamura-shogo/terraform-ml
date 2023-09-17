
resource "aws_ecr_repository" "main" {
  name = var.ecr_repository_name
  force_delete = true
}
