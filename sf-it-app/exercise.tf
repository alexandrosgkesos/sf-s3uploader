locals {
  bucket_name = "sf-s3uploads"
  region      = "eu-central-1"

  tags = {
    Application = "sf-s3uploader"
  }
}

# To get the account ID
data "aws_caller_identity" "current" {}

#Let's use modules here
#########################################
# S3 bucket
#########################################
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = ["arn:aws:s3:::${local.bucket_name}/*"]
  }
}

module "s3_uploader_bucket" {
  source        = "github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=v3.4.0"
  bucket        = local.bucket_name
  acl           = "public-read"
  force_destroy = true #this is for easier resource deletion

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  cors_rule = [
    {
      allowed_methods = ["PUT", "GET", "HEAD"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
    }
  ]

  tags = local.tags
}

#########################################
# API Gateway
#########################################
resource "aws_apigatewayv2_api" "s3_uploader_api_gateway" {
  name          = local.tags.Application
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for S3Uploader"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
  }

  target = module.s3_uploader_lambda_function.lambda_function_arn
  route_key = "GET /upload"

  tags = local.tags
}

##########################################
## IAM policy
##########################################
module "s3_uploader_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.5.1"

  name        = "${local.tags.Application}-Policy"
  path        = "/"
  description = "Policy to be used for sf-s3uploader Role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:PutLifecycleConfiguration"
        ],
        "Resource": [
            "arn:aws:s3:::${local.bucket_name}",
            "arn:aws:s3:::${local.bucket_name}/*"
        ],
        "Effect": "Allow"
    }
  ]
}
EOF

  tags = local.tags
}

#########################################
# Lambda function
#########################################
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda.zip"
  output_file_mode = "0666"
	source_dir  = "${path.module}/src"
}

module "s3_uploader_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 3.0"

  function_name = local.tags.Application
  description   = "Lambda function for S3Uploader"
  handler       = "app.handler"
  runtime       = "nodejs12.x"

  create_role     = true
  publish   = true

  attach_policy = true
  policy = module.s3_uploader_iam_policy.arn

  create_package = false
  local_existing_package         = "/tmp/lambda.zip"

  environment_variables = {
    UploadBucket = local.bucket_name
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${local.region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.s3_uploader_api_gateway.id}/*/GET/upload"
    }
  }

  tags = local.tags

}
