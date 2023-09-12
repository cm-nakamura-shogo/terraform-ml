variable function_name {}
variable image_uri {}
variable iam_role_arn {}
variable bucket_name {}
variable object_input_prefix {}
variable object_output_prefix {}

resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  role             = var.iam_role_arn
  image_uri        = "${var.image_uri}:latest"
  package_type     = "Image"
  timeout          = 600
  memory_size      = 8192

  ephemeral_storage {
    size = 8192
  }

  image_config {
    command = ["lambda_handler.handler"]
  }

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      OBJECT_INPUT_PREFIX = var.object_input_prefix
      OBJECT_OUTPUT_PREFIX = var.object_output_prefix
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.log
  ]
}

resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/lambda/${var.function_name}"
}
