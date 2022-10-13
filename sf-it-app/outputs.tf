output "api_gateway_endpoint" {
  depends_on = [aws_apigatewayv2_api.s3_uploader_api_gateway]
  value      = aws_apigatewayv2_api.s3_uploader_api_gateway.api_endpoint
}

output "s3_bucket_name" {
  depends_on = [module.s3_uploader_bucket]
  value      = module.s3_uploader_bucket.s3_bucket_id
}
