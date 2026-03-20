# IAM ROLE for app01 to access S3 bucket
# Prerequisites: s3 bucket with an artifact on it

# Name: s3-admin
# Role: AmazonS3FullAccess

# Attach role to app01
resource "aws_iam_role" "s3_admin" {
  name = "s3-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.s3_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "s3_admin" {
  name = "s3-admin"
  role = aws_iam_role.s3_admin.name
}
