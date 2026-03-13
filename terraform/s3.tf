resource "aws_s3_bucket" "postgresql_backups" {
  bucket = "maskio-postgresql-backups-2026"
}

resource "aws_s3_bucket_public_access_block" "backups_privacy" {
  bucket = aws_s3_bucket.postgresql_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "ec2_backup_role" {
  name = "ec2_postgresql_backup_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })
}

resource "aws_iam_role_policy" "s3_backup_policy" {
  name = "s3_backup_policy"
  role = aws_iam_role.ec2_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.postgresql_backups.arn,
          "${aws_s3_bucket.postgresql_backups.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_postgresql_instance_profile"
  role = aws_iam_role.ec2_backup_role.name
}