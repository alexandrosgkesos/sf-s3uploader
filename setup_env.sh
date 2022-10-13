#!/bin/bash
echo -e "This is a wrapper of TF code which create
a new organization and a new account with a user.
Then it deploys a serverless app (Lambda, S3, Cloudwatch)\n"

#Get the root account AWS credentials from user
read -p "Please provide the AWS_ACCESS_KEY_ID: " aws_access_key_id
read -p "Please provide the AWS_SECRET_ACCESS_KEY: " aws_secret_access_key

#Export AWS creds of root account's user
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key

#Set the TF path of the new org/acc/user code
export tf_path="sf-it-root"

#Terraform initialization and apply for the org/acc/user creation
terraform -chdir=$tf_path init && terraform -chdir=$tf_path apply -auto-approve || (( echo -e "\n---> Terraform Apply failed" && exit 1 ))

# Export AWS creds of new account's user
export AWS_ACCESS_KEY_ID=$(terraform -chdir=$tf_path output -raw assignment_user_id)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=$tf_path output -raw assignment_user_secret)

#Set the TF path of the app code
export tf_path="sf-it-app"

#Terraform initialization and apply for the org/acc/user creation
terraform -chdir=$tf_path init && terraform -chdir=$tf_path apply -auto-approve || (( echo -e "\n---> Terraform Apply failed" && exit 1 ))
