output "apiExecutionArn" {
    value = aws_api_gateway_rest_api.techx-tf-api-gateway.execution_arn // i am right to have gotten the execution arn from the rest api resource. 
}