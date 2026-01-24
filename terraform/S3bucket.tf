resource "aws_s3_bucket" "upload_bucket" {
  bucket = "thimeth-file-upload-bucket"
  force_destroy = true
}


resource "aws_iam_policy" "s3_upload_policy" {
  name = "ecs-s3-upload-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.upload_bucket.arn,
          "${aws_s3_bucket.upload_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRoleS3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_task_s3_policy_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}
