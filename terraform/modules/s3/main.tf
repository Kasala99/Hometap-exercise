resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
 bucket = "sam-bucket-name"

 rule {
   apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
   }
 }

 #tags = {
 #   Name = "samBucket"
 #}      
}
 
# IAM policy
resource "aws_iam_policy" "s3_policy" {
 name        = "s3_policy"
 description = "Policy for S3 access"
 policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::sam-bucket-name"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::sam-bucket-name/*"]
    }
 ]
}
EOF
}

# IAM role
resource "aws_iam_role" "s3_role" {
 name = "s3_role"
 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
 ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_role_policy_attachment" {
 role       = aws_iam_role.s3_role.name
 policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_s3_bucket_versioning" "hometap" {
 bucket = "sam-bucket-name"
 versioning_configuration {
   status = "Enabled"
 }
}


