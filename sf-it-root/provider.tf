terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0.11"
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.assignment_acc.id}:role/Admin"
  }

  alias  = "users"
  region = "eu-central-1"
}
