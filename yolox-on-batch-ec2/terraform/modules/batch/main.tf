
// ジョブ定義
resource "aws_batch_job_definition" "main" {
  name                 = "${var.project_prefix}-job-definition"
  type                 = "container"
  container_properties = jsonencode({
    command = [
      "python", "run.py",
      "--input-bucket-name", "Ref::input_bucket_name",
      "--input-object-key", "Ref::input_object_key"
    ]
    image = "${var.image_uri}:latest"
    jobRoleArn = "${var.job_role_arn}"
    resourceRequirements = [
      {
        type = "VCPU"
        value = "1"
      },
      {
        type = "MEMORY"
        value = "2048"
      }
    ]
    executionRoleArn = "${var.job_execution_role_arn}"
    environment = "${var.environments}"
  })
}

// コンピューティング環境
resource "aws_batch_compute_environment" "fargate" {
  compute_environment_name = "${var.project_prefix}-compute-environment"

  compute_resources {
    max_vcpus = 16

    security_group_ids = [
      var.security_group_id
    ]

    subnets = [
      var.subnet_id
    ]

    type = "FARGATE"
  }

  type         = "MANAGED"
  service_role = var.service_role_arn
}

# ジョブキュー
resource "aws_batch_job_queue" "job_queue" {
  name                 = "${var.project_prefix}-job-queue"
  state                = "ENABLED"
  priority             = 0
  compute_environments = [aws_batch_compute_environment.fargate.arn]
}
