output "assignment_acc_id" {
  depends_on = [aws_organizations_account.assignment_acc]
  value      = aws_organizations_account.assignment_acc.id
}

output "assignment_user_id" {
  depends_on = [aws_iam_access_key.assignment_user_key]
  value      = aws_iam_access_key.assignment_user_key.id

  provider = aws.users
}

output "assignment_user_secret" {
  depends_on = [aws_iam_access_key.assignment_user_key]
  value      = aws_iam_access_key.assignment_user_key.secret
  sensitive = true

  provider = aws.users
}
