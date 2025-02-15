# Creates the main REST API Gateway for text summarization
resource "aws_api_gateway_rest_api" "text_summarization_api" {
  name        = "text-summarization-api"
  description = "API for text summarization"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Creates the API resource/endpoint path for image generation
resource "aws_api_gateway_resource" "text_summarization_resource" {
  rest_api_id = aws_api_gateway_rest_api.text_summarization_api.id
  parent_id   = aws_api_gateway_rest_api.text_summarization_api.root_resource_id
  path_part   = "summarize"
}

# Defines the POST method for the text summarization endpoint
resource "aws_api_gateway_method" "create_text_summarization_method" {
  rest_api_id   = aws_api_gateway_rest_api.text_summarization_api.id
  resource_id   = aws_api_gateway_resource.text_summarization_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrates the API endpoint with the Lambda function
resource "aws_api_gateway_integration" "create_text_summarization_integration" {
  rest_api_id             = aws_api_gateway_rest_api.text_summarization_api.id
  resource_id             = aws_api_gateway_resource.text_summarization_resource.id
  http_method             = aws_api_gateway_method.create_text_summarization_method.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.text_summarization.invoke_arn
  integration_http_method = "POST"
}

# Grants API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "create_text_summarization_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.text_summarization.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.text_summarization_api.execution_arn}/*/*"
}

# Defines the successful (200) response for the API method
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.text_summarization_api.id
  resource_id = aws_api_gateway_resource.text_summarization_resource.id
  http_method = aws_api_gateway_method.create_text_summarization_method.http_method
  status_code = "200"
}

# Configures the response integration with a success message
resource "aws_api_gateway_integration_response" "create_text_summarization_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.text_summarization_api.id
  resource_id = aws_api_gateway_resource.text_summarization_resource.id
  http_method = aws_api_gateway_method.create_text_summarization_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [aws_api_gateway_integration.create_text_summarization_integration]

  response_templates = {
    "application/json" = "{\"message\": \"Text summarization created successfully\"}"
  }
}

# Creates a deployment for the API changes
# The triggers block ensures the API is redeployed when the resource, method, or integration changes
# by creating a hash of their configurations. The depends_on ensures methods exist before deployment.
resource "aws_api_gateway_deployment" "text_summarization_deployment" {
  rest_api_id = aws_api_gateway_rest_api.text_summarization_api.id

  triggers = {
    redeployment = sha1(join(",", [
      jsonencode(aws_api_gateway_resource.text_summarization_resource),
      jsonencode(aws_api_gateway_method.create_text_summarization_method),
      jsonencode(aws_api_gateway_integration.create_text_summarization_integration)
    ]))
  }

  depends_on = [
    aws_api_gateway_method.create_text_summarization_method,
    aws_api_gateway_integration.create_text_summarization_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Creates a development stage for the API deployment
resource "aws_api_gateway_stage" "text_summarization_stage" {
  deployment_id = aws_api_gateway_deployment.text_summarization_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.text_summarization_api.id
  stage_name    = "dev"
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_api_gateway_stage.text_summarization_stage.invoke_url}/summarize"
}
