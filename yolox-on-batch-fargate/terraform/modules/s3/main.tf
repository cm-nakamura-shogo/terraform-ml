
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.main.id
  eventbridge = true
}

resource "aws_s3_object" "object_input" {
  bucket = var.bucket_name
  key    = var.object_input_prefix
  depends_on = [aws_s3_bucket.main]
}

resource "aws_s3_object" "object_output" {
  bucket = var.bucket_name
  key    = var.object_output_prefix
  depends_on = [aws_s3_bucket.main]
}

resource "aws_s3_object" "object_model_file" {
  bucket = var.bucket_name
  key    = "asset/yolox_l_8x8_300e_coco_20211126_140236-d3bd2b23.pth"
  source = "../../../asset/yolox_l_8x8_300e_coco_20211126_140236-d3bd2b23.pth"
  depends_on = [aws_s3_bucket.main]
}