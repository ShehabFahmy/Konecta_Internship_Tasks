resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name
  protocol_type = "HTTP"  # Creates a lightweight HTTP API Gateway (cheaper than REST API Gateway).

  cors_configuration {
    # Allow requests from any domain (important since your frontend is hosted on GitHub Pages, a different domain than the API).
    allow_origins = ["*"]
    allow_methods = ["GET","POST","OPTIONS"]
    allow_headers = ["Content-Type","Authorization"]
    max_age       = 3600
  }
}

# Connect API Gateway to the Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  
  # API Gateway sends the whole HTTP request as-is to Lambda and expects Lambda to return a properly formatted HTTP response.
  integration_type = "AWS_PROXY"
  
  # Lambda function to invoke.
  integration_uri  = aws_lambda_function.history_fn.invoke_arn
  
  # API Gateway v2 payload format, matches Node.js/Python AWS Lambda runtimes.
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_history" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /history"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "post_save" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /save-history"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deployment environment of the API
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"  # Special stage name, means "no need to add /dev or /prod in the URL".
  auto_deploy = true  # Every Terraform change is automatically live, no need to manually deploy the API.
}
