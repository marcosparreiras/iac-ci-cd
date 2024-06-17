resource "aws_ecr_repository" "rocketseat_ci_api" {
  name                 = "rocketseat_ci"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    IAC = "True"
  }
}
