#!/bin/bash
#Get the root account AWS credentials from user
read -p "Please provide the AWS_ACCESS_KEY_ID: " aws_access_key_id
read -p "Please provide the AWS_SECRET_ACCESS_KEY: " aws_secret_access_key

#Export AWS creds of root account's user
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key

#Switch to root's TF state, as the user's credentials/outputs are stored there
export tf_path="sf-it-root"

# Export AWS creds of new account's user
export AWS_ACCESS_KEY_ID=$(terraform -chdir=$tf_path output -raw assignment_user_id)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=$tf_path output -raw assignment_user_secret)

#Switch to the app's TF state to get the bucket name
export tf_path="sf-it-app"

#Get the bucket name (there is only one bucket in our new account)
bucket_name=$(terraform -chdir=$tf_path output -raw s3_bucket_name)

#Get the S3 bucket policy status = if bucket is Public
bucket_policy=$(aws s3api get-bucket-policy-status --bucket $bucket_name --output json | jq .PolicyStatus.IsPublic)

echo "This script checks if the bucket is public or not"
echo "which is...$bucket_policy"
