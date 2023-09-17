
# 信頼ポリシー
data "aws_iam_policy_document" "trust_ecs_tasks" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ジョブロール
resource "aws_iam_role" "job_role" {
  name = "${var.project_prefix}-job-role"
  assume_role_policy = data.aws_iam_policy_document.trust_ecs_tasks.json
}

# IAMポリシーデータ
data "aws_iam_policy_document" "job_role" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "s3-object-lambda:*"
    ]
    resources = [
      "arn:aws:s3:::${var.project_prefix}-${var.account_id}",
      "arn:aws:s3:::${var.project_prefix}-${var.account_id}/*"
    ]
  }
}

# IAMポリシー
resource "aws_iam_policy" "job_role" {
  name = "${var.project_prefix}-job-role-policy"
  policy = data.aws_iam_policy_document.job_role.json
}

# IAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "job_role" {
  role       = aws_iam_role.job_role.name
  policy_arn = aws_iam_policy.job_role.arn
}


# ジョブ実行ロール
resource "aws_iam_role" "job_execution_role" {
  name = "${var.project_prefix}-job-execution-role"
  assume_role_policy = data.aws_iam_policy_document.trust_ecs_tasks.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# 信頼ポリシー
data "aws_iam_policy_document" "trust_batch" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# サービスロール
resource "aws_iam_role" "batch_service_role" {
  name = "${var.project_prefix}-batch-service-role"
  assume_role_policy = data.aws_iam_policy_document.trust_batch.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  ]
}

# 信頼ポリシー
data "aws_iam_policy_document" "trust_events" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# 実行ロール
resource "aws_iam_role" "events_execution_role" {
  name = "${var.project_prefix}-events-execution-role"
  assume_role_policy = data.aws_iam_policy_document.trust_events.json
}


# IAMポリシーデータ
data "aws_iam_policy_document" "events_execution_role" {
  statement {
    effect = "Allow"
    actions = [
      "batch:SubmitJob"
    ]
    resources = [
      "arn:aws:batch:ap-northeast-1:${var.account_id}:job/${var.project_prefix}-job",
      "arn:aws:batch:ap-northeast-1:${var.account_id}:job-definition/${var.project_prefix}-job-definition:*",
      "arn:aws:batch:ap-northeast-1:${var.account_id}:job-queue/${var.project_prefix}-job-queue"
    ]
  }
}

# IAMポリシー
resource "aws_iam_policy" "events_execution_role" {
  name = "${var.project_prefix}-events-execution-role-policy"
  policy = data.aws_iam_policy_document.events_execution_role.json
}

# IAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "events_execution_role" {
  role       = aws_iam_role.events_execution_role.name
  policy_arn = aws_iam_policy.events_execution_role.arn
}
