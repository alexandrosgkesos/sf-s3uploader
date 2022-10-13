# File uploader
This example creates an AWS serverless "file uploader" app in a new AWS account with a publicly accessible S3 bucket.

It is a two-step upload

* Calls an Amazon API Gateway endpoint, which invokes the getSignedURL Lambda function. This gets a signed URL from the S3 bucket.
* Directly upload the file from the application to the S3 bucket.

![Architecture](docs/arch.png)

Utilizes API Gateway, Lambda, S3, IAM, Cloudwatch.

Created mainly with Terraform(TF) code, some Bash scripts and NodeJS for the Lambda code.

## Requirements
- AWS CLI
- Terraform

## Installation Instructions
- Create an AWS account if you do not have one already and login.
- Clone the repo onto your local development machine using git clone.
- In "setup_env.tf" file, line 10, put an email for the new AWS account that will be created.

### Deploying the new account and the application
Everything is done by executing the "setup_env.sh" file


### Environment deployment
setup_env.sh - Bash script that connects to the root account (credentials have to be provided by user) and runs TF code to create:
* An Organization
* Service control policy (SCP) with limited AWS permissions
* Account with the SCP attached to it and an Admin Role that trusts the Root account
* By assuming the Admin Role, it creates a user and his access key in the new account

The TF code is at "sf-it-root" folder
  * setup_env.tf: Creates the resources
  * provider.tf: TF/AWS provider configuration
  * outputs.tf: Exposes the new user credentials

#### Notes
For this scenario, we create a user in the new account, even if an assumable Role would made things easier, to deploy the App's resources.
To do so, we need to use the user ID/Secret in our script for authentication. The secret is currently being stored in the TF state in an non-encrypted format.
Reason is to be fetched more easily by the script. For hardening, encryption/decryption with a PGP
key can be implemented [(more)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key#example-usage).
Alternatively, the access key can be created with AWS CLI. In this case we can grab the ID/secret from the output.
```
aws iam create-access-key --user-name "Assignment_User"
```

### Serverless app deployment
(The whole implementation is based on an official AWS Sample ([click me](https://github.com/aws-samples/amazon-s3-presigned-urls-aws-sam)),
which creates all the resources with a AWS SAM template. In our case, each resource is defined separately.)

setup_env.sh - After the environment deployment, it calls another TF code under "sf-it-app" to create:
* S3 bucket
* API Gateway
* Lambda function
* IAM Policy for the Lambda IAM Role

Code under "sf-it-app"
* exercise.tf: Resources are defined here
* provider.tf: TF/AWS provider configuration
* outputs.tf: Exposes the API Gateway's endpoint and the S3 bucket's name
* "src" folder: Lambda function's code
* "frontend" folder: HTML file for "easier" tests of the application (needs to be uploaded to the S3 bucket)

#### Notes
There was only a basic tag used (Application), but in a proper deployment there would be more (eg. owner/repository/environment/managedby)

There are two local TF states being created. One in each folder (Root/App).
These are being used as well for the [environment's teardown](#environment-teardown)

## Environment teardown
teardown_env.sh - Bash script that destroys the app and then the new user/new account/organization policy
- Asks for Root account's user credentials.
- Fetches and authenticates with the new account's user credentials
- Destroys the app resources with "terraform destroy" targeting the TF state of the Application
- Switches back to Root account's user credentials
- Destroys the User/Account/Org policy with "terraform destroy" targeting the TF state of the Root account

## Check if S3 bucket is public
test.sh
- Asks for Root account's user credentials.
- Fetches and authenticates with the new account's user credentials
- Fetches the S3 bucket name from the App's TF state output
- Tests with [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/s3api/get-bucket-policy-status.html) if the S3 Bucket is public
- and 'echo'es a message with the findings.


## Bonus
#### Create a Cloudformation template for SCP provisioning

Unfortunately, that seems [not supported yet](https://github.com/aws-cloudformation/cloudformation-coverage-roadmap/issues/806)
