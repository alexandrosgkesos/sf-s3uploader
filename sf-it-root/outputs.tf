output "assignment_user_id" {
  depends_on = [aws_iam_access_key.assignment_user_key]
  value      = aws_iam_access_key.assignment_user_key.id
}

output "assignment_user_secret" {
  depends_on = [aws_iam_access_key.assignment_user_key]
  value      = aws_iam_access_key.assignment_user_key.secret
  sensitive = true
}
