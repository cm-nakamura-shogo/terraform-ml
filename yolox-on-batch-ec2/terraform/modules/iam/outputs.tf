output "job_role_arn" {
  value = aws_iam_role.job_role.arn
}

output job_execution_role_arn {
  value = aws_iam_role.job_execution_role.arn
}

output batch_service_role_arn {
  value = aws_iam_role.batch_service_role.arn
}

output events_execution_role_arn {
  value = aws_iam_role.events_execution_role.arn
}