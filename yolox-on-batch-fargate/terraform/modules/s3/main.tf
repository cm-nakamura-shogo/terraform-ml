variable bucket_name {}
variable object_input_prefix {}
variable object_output_prefix {}
variable lamba_function_arn {}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lamba_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = var.lamba_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.permission]
}

resource "aws_s3_object" "object_input" {
  bucket = var.bucket_name
  key    = var.object_input_prefix
}

resource "aws_s3_object" "object_output" {
  bucket = var.bucket_name
  key    = var.object_output_prefix
}

resource "aws_s3_object" "object_model_file" {
  bucket = var.bucket_name
  key    = "asset/yolox_l_8x8_300e_coco_20211126_140236-d3bd2b23.pth"
  source = "../../../asset/yolox_l_8x8_300e_coco_20211126_140236-d3bd2b23.pth"
}