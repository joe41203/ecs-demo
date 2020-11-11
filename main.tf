module "network" {
  source = "terraform-aws-modules/vpc/aws"

  name                   = "${local.project_code}-vpc"
  cidr                   = "10.0.0.0/16"
  azs                    = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets         = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  tags                   = local.default_tags
}

module "ecr_repository" {
  source                                    = "./modules/aws-ecr"
  repository_name                           = "${local.project_code}-nginx"
  image_tag_mutability                      = "MUTABLE"
  image_scanning_configuration_scan_on_push = true
  keep_image_size                           = "3"
  tags                                      = local.default_tags
}


resource "aws_ecs_cluster" "this" {
  name               = local.project_code
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
