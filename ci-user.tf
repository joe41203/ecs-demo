resource "aws_iam_user" "ci" {
  name = "${local.project_code}-github-action"
  path = "/"

  tags = {
    Name = "${local.project_code}-github-action"
    CI   = true
  }
}

resource "aws_iam_user_policy_attachment" "ci" {
  user       = aws_iam_user.ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
