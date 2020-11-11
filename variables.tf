locals {
  region          = "ap-northeast-1"
  credential_path = "~/.aws/credentials"
  profile         = "private"
  project_code    = "ecs-demo"
  default_tags = {
    Name = local.project_code
  }
}
