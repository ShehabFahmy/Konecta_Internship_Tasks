output "api_invoke_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
  description = "Invoke URL (use this as API base for frontend calls)"
}
