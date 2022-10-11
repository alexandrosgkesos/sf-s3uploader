resource "aws_organizations_organization" "sf_organization" {
  feature_set = "ALL" #needed for SCP
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

resource "aws_organizations_account" "assignment_acc" {
  name              = "Assignment(temp)"
  email             = "agesos@gmail.com"
  role              = "OrganizationRole"
  close_on_deletion = true
}

#In a specific scenario (or in a prod env) permissions would be more strict
resource "aws_organizations_policy" "allow_assignment_privs" {
  name        = "Assignment_limited_perms"
  description = "Allow limited permissions just for the assignment"

  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
        "s3:*",
        "cloudwatch:*",
        "lambda:*",
        "iam:*"
    ],
    "Resource": "*"
  }
}
CONTENT
}

resource "aws_organizations_policy_attachment" "account" {
  policy_id = aws_organizations_policy.allow_assignment_privs.id
  target_id = aws_organizations_organization.assignment_acc.id
}


resource "aws_iam_user" "assignment_user" {
  depends_on = [aws_organizations_account.assignment_acc]
  name       = "Assignment_User"

  provider = aws.users
}

resource "aws_iam_access_key" "assignment_user_key" {
  depends_on = [aws_organizations_account.assignment_acc]
  user       = aws_iam_user.assignment_user.name

  provider = aws.users
}

#No request for strict perms. SCP sets already a limit.
resource "aws_iam_user_policy" "assignment_user_policy" {
  depends_on = [aws_organizations_account.assignment_acc]
  name       = "Assignment_User_Policy"
  user       = aws_iam_user.assignment_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  provider = aws.users

}
