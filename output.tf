output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_api_gateway_stage.text_summarization_stage.invoke_url}/text_summarization"
}
