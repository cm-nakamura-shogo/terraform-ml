
variable repository_name {}

resource "aws_ecr_repository" "main" {
  name = var.repository_name
  force_delete = true
}
