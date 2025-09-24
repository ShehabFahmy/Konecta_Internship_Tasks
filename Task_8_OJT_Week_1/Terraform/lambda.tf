# Compresse the contents of the lambda/ folder into a .zip file (lambda.zip).
# AWS Lambda requires deployment packages to be .zip files.
# Without this step, you’d need to manually zip your code and update it each time.
# Terraform’s archive_file provider automates zipping and also computes a hash (output_base64sha256)
#   so Terraform knows when your code has changed and triggers a redeploy automatically.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "history_fn" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_role.arn
  # index = the filename (e.g., index.js), handler = the exported function inside index.js
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  # Ensures Lambda is updated whenever your code changes (Terraform compares the hash of your .zip)
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.history.bucket
    }
  }
}

# Grant API Gateway permission to invoke your Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.history_fn.function_name
  principal     = "apigateway.amazonaws.com"  # Means: only API Gateway can use this permission

  # Restrict invocation to your specific API Gateway stage
  source_arn = "${aws_apigatewayv2_stage.default.execution_arn}/*/*"
}
