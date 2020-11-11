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
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "5.6.0"
  name               = local.project_code
  vpc_id             = module.network.vpc_id
  load_balancer_type = "application"
  internal           = false
  subnets            = module.network.public_subnets
  security_groups    = [aws_security_group.http.id, aws_security_group.https.id, aws_security_group.common.id]
  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"

      health_check = {
        interval = 20
      }
    }
  ]
  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    }
  ]
}

data "template_file" "container_definitions" {
  template = file("task-definitions/fargate-nginx.json")

  vars = {
    image = "${module.ecr_repository.repository_url}:latest"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  container_definitions    = data.template_file.container_definitions.rendered
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_execution.arn
  execution_role_arn       = aws_iam_role.task_execution.arn
}


resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = module.network.private_subnets
    security_groups  = [aws_security_group.common.id]
    assign_public_ip = false
  }
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "awslogs-nginx-ecs"
}
