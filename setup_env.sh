#!/bin/bash
echo "This is a wrapper of TF code which create
a new organization and a new account with a user.
Then it deploys a serverless app (Lambda, S3, Cloudwatch)\n"

#Get the AWS credentials from user
read -p "Please provide the AWS_ACCESS_KEY_ID: " aws_access_key_id
read -p "Please provide the AWS_SECRET_ACCESS_KEY: " aws_secret_access_key

#Export AWS creds of root account's user
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key

#Set the TF path of the new org/acc/user code
export tf_path="sf-it-root"

#Terraform initialization and apply for the org/acc/user creation
terraform -chdir=$tf_path init && terraform -chdir=$tf_path apply -auto-approve || echo "\n---> Terraform Apply failed" && exit 1

#Utilize the outputs exported in the TF code to:
# - assume the new account's role in order to fetch the user related outputs
aws sts assume-role --role-arn "arn:aws:iam::$(terraform output -raw assignment_acc_id):role/Admin" --role-session-name "one_off_session"

# - Export AWS creds of new account's user
export AWS_ACCESS_KEY_ID=$(terraform output -raw assignment_user_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw assignment_user_secret)

#Set the TF path of the app code
export tf_path="sf-it-app"

#Terraform initialization and apply for the org/acc/user creation
terraform -chdir=$tf_path init && terraform -chdir=$tf_path apply -auto-approve || echo "\n---> Terraform Apply failed" && exit 1
