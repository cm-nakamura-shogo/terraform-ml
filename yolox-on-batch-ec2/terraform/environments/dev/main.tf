
provider "aws" {
  default_tags {
    tags = {
      project_prefix = var.project_prefix
    }
  }
}

module vpc {
  source = "../../modules/vpc"
  project_prefix = var.project_prefix
}

module ecr {
  source = "../../modules/ecr"
  project_prefix = var.project_prefix
  ecr_repository_name = local.ecr_repository_name
}

module iam {
  source="../../modules/iam"
  project_prefix = var.project_prefix
  account_id = local.account_id
}

module batch {
  source = "../../modules/batch"
  project_prefix = var.project_prefix
  image_uri = local.ecr_image_uri
  subnet_id = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
  job_role_arn = module.iam.job_role_arn
  job_execution_role_arn = module.iam.job_execution_role_arn
  service_role_arn = module.iam.batch_service_role_arn
  environments = local.environments
}

module event_bridge {
  source = "../../modules/event_bridge"
  project_prefix = var.project_prefix
  execution_role_arn = module.iam.events_execution_role_arn
  job_queue_arn = module.batch.job_queue_arn
  job_definition_arn = module.batch.job_definition_arn
  bucket_name = local.bucket_name
  object_input_prefix = local.object_input_prefix
}

module s3 {
  source="../../modules/s3"
  project_prefix = var.project_prefix
  bucket_name=local.bucket_name
  object_input_prefix=local.object_input_prefix
  object_output_prefix=local.object_output_prefix
}
