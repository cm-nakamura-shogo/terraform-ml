
# ルール
resource "aws_cloudwatch_event_rule" "rule" {
  name        = "${var.project_prefix}-event-rule"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : ["${var.bucket_name}"]
      },
      "object" : {
        "key" : [{
          "prefix" : "${var.object_input_prefix}"
        }]
      }
    }
  })
}

# ターゲット
resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.rule.name

  arn = var.job_queue_arn # aws_batch_job_queue.job_queue.arn # ジョブキューのARN

  batch_target {
    job_definition = var.job_definition_arn
    job_name       = "${var.project_prefix}-job"
  }

  role_arn = var.execution_role_arn

  input_transformer {
    input_paths = {
      "input_bucket_name" : "$.detail.bucket.name",
      "input_object_key" : "$.detail.object.key"
    }
    input_template = <<-TEMPLATE
      {"Parameters": {"input_bucket_name":"<input_bucket_name>", "input_object_key":"<input_object_key>"}}
    TEMPLATE
  }
}
