
data "aws_region" "current" {}

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
    environment = "${var.environments}"

    logConfiguration = {
      logDriver     = "awslogs",
      options = {
        awslogs-group = "/aws/batch/job/${var.project_prefix}"
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/batch/job/${var.project_prefix}"
}

// コンピューティング環境
resource "aws_batch_compute_environment" "ec2" {
  compute_environment_name = "${var.project_prefix}-compute-environment"

  compute_resources {
    instance_role = var.instance_profile_arn
    instance_type = ["g4dn.xlarge"]
    max_vcpus = 16

    security_group_ids = [
      var.security_group_id
    ]

    subnets = [
      var.subnet_id
    ]

    type = "EC2"
  }

  type         = "MANAGED"
  service_role = var.service_role_arn
}

# ジョブキュー
resource "aws_batch_job_queue" "job_queue" {
  name                 = "${var.project_prefix}-job-queue"
  state                = "ENABLED"
  priority             = 0
  compute_environments = [aws_batch_compute_environment.ec2.arn]
}
