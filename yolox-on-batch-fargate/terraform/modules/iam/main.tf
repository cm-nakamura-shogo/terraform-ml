variable iam_role_name {}
variable iam_policy_name {}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.main.json
  inline_policy {
    name = var.iam_policy_name
    policy = jsonencode({
      "Version" : "2012-10-17"
      "Statement" : [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:*",
            "s3-object-lambda:*"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}
