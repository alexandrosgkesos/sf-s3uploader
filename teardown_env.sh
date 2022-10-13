#!/bin/bash
echo -e "Time to destroy everything we've built\n"

#Procedure
#We take Root Account's credentials. With these we are able to get the new account's user credentials
#We authenticate with the user credentials and destroy the App
#Then we switch back to root account's credentials and destroy the account as well

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

#Terraform destroy of the App
terraform -chdir=sf-it-app destroy || (( echo "\n---> Terraform destroy failed" && exit 1))

#Export AWS creds of root account's user
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key

#Terraform destroy of the user/account/org policy
terraform -chdir=sf-it-root destroy || (( echo "\n---> Terraform destroy failed" && exit 1)) 

echo -e "Probably everything is destroyed\n"
