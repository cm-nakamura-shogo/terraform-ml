data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  bucket_name = "${var.project_prefix}-${local.account_id}"
  object_input_prefix = "input/"
  object_output_prefix = "output/"
  ecr_repository_name = var.project_prefix
  ecr_image_uri = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.ecr_repository_name}"
  environments = [
    {
      name  = "BUCKET_NAME"
      value = "${local.bucket_name}"
    },
    {
      name  = "OBJECT_INPUT_PREFIX"
      value = "${local.object_input_prefix}"
    },
    {
      name  = "OBJECT_OUTPUT_PREFIX"
      value = "${local.object_output_prefix}"
    }
  ]
}