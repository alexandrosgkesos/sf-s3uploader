#Let's use a module for a change
module "assignment_s3_bucket" {
  source        = "github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=v3.4.0"
  bucket        = "sf-assignment"
  acl           = "public-read"
  force_destroy = true #this is for easier resource deletion

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::sf-assignment/*",
      "Principal": {
        "AWS": "*"
      }
    }
  ]
}
POLICY
}
