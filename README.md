# File uploader
## Abstract
This is an AWS serverless "file uploader" app that can be built and destroyed on demand.

Created mainly with Terraform(TF) code, some Bash scripts

## Setting up the Environment
setup_env.sh - Bash script that connects to the root account and runs TF code to create:
* An Organization
* Service control policy (SCP) with limited AWS permissions
* Account with the SCP attached to it and an Admin Role that trusts the Root account
* By assuming the Admin Role, it creates a user and his access key in the new account

The TF code is at "sf-it-root" folder
  * setup_env.tf: Creates the resources
  * provider.tf: TF/AWS provider configuration
  * outputs.tf: Exposes some info to be used later in the script

#### Notes
We need a user in the new account (instead of an assumable Role, which would made things easier) to be able to
deploy the App's resources. To do so we need to use the user ID/Secret in our script for authentication.
The secret is currently being stored in the TF state in an non-encrypted format
Reason is to be fetched more easily by the script. For hardening, encryption/decryption with a PGP
key can be implemented [(more)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key#example-usage).
Alternatively, the access key can be created with AWS CLI. In this case we can grab the ID/secret from the output.
```
aws iam create-access-key --user-name "Assignment_User"
```

## Setting up the serverless app
setup_env.sh
* After the environment creation it calls another TF code under "sf-it-app"

## Check if S3 bucket is public
test.sh - Bash script which authenticates with the user credentials and checks with
[AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/s3api/get-bucket-policy-status.html) if the S3 Bucket is public


## Bonus
Create a Cloudformation template for SCP provisioning
Unfortunately that's [not supported yet](https://github.com/aws-cloudformation/cloudformation-coverage-roadmap/issues/806)
