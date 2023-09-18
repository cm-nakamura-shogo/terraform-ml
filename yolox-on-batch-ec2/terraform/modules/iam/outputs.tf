output "job_role_arn" {
  value = aws_iam_role.job_role.arn
}

output instance_profile_arn {
  value = aws_iam_instance_profile.instance_profile.arn
}

output batch_service_role_arn {
  value = aws_iam_role.batch_service_role.arn
}

output events_execution_role_arn {
  value = aws_iam_role.events_execution_role.arn
}