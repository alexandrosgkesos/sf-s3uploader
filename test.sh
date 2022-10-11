#!/bin/bash
#Get the stored credentials
source ./creds

#Get the bucket name (there is only one bucket in our new account)
bucket_name=$(aws s3api list-buckets --output json | jq .Buckets[0].Name)

#Get the S3 bucket policy status = if bucket is Public
bucket_policy=$(aws s3api get-bucket-policy-status --bucket $bucket_name --output json | jq .PolicyStatus.IsPublic)

echo "This script checks if the bucket is public or not"
echo "which is...$bucket_policy"
