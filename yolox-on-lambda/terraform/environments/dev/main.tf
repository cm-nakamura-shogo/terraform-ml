
variable "project_prefix" {}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name
  bucket_name          = "${var.project_prefix}-${local.account_id}"
  object_input_prefix  = "input/"
  object_output_prefix = "output/"
  function_name        = "${var.project_prefix}"
  iam_role_name        = "${var.project_prefix}-iam-role"
  iam_policy_name      = "${var.project_prefix}-iam-policy"
  repository_name      = "${var.project_prefix}"
  image_uri            = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.repository_name}"
}

module ecr {
  source="../../modules/ecr"
  repository_name=local.repository_name
}

module iam {
  source="../../modules/iam"
  iam_role_name=local.iam_role_name
  iam_policy_name=local.iam_policy_name
}

module lambda {
  source="../../modules/lambda"
  function_name=local.function_name
  image_uri=local.image_uri
  iam_role_arn=module.iam.iam_role_arn
  bucket_name=local.bucket_name
  object_input_prefix=local.object_input_prefix
  object_output_prefix=local.object_output_prefix
}

module s3 {
  source="../../modules/s3"
  bucket_name=local.bucket_name
  object_input_prefix=local.object_input_prefix
  object_output_prefix=local.object_output_prefix
  lamba_function_arn=module.lambda.lamba_function_arn
}
