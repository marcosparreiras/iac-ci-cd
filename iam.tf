resource "aws_iam_openid_connect_provider" "oidc_git" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  tags = {
    IAC = "True"
  }

}


resource "aws_iam_role" "ecr-role" {
  name       = "ecr-role"
  depends_on = [aws_iam_openid_connect_provider.oidc_git]
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::381492193067:oidc-provider/token.actions.githubusercontent.com"
        },
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : ["sts.amazonaws.com"],
            "token.actions.githubusercontent.com:sub" : [
              "repo:marcosparreiras/ci-cd:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
    }
  )
  inline_policy {
    name = "ecr_app_permission"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid = "Statement1",
        Action = [
          "apprunner:*"
        ]
        Effect   = "Allow"
        Resource = "*"
        },
        {
          Sid = "Statement2"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid = "Statement3",
          Action = [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "app_runner_role" {
  name       = "app_runner_role"
  depends_on = [aws_iam_openid_connect_provider.oidc_git]
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
  tags = {
    IAC = "True"
  }
}
