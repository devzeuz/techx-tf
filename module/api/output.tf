output "apiExecutionArn" {
    value = aws_api_gateway_rest_api.techx-tf-api-gateway.execution_arn // i am right to have gotten the execution arn from the rest api resource. 
}

output "rest-api-id" {
    value = aws_api_gateway_rest_api.techx-tf-api-gateway.id
}

output "courses-resource-id" {
    value = aws_api_gateway_resource.techx-tf-courses-resource.id
}

output "id-courses-id" {
    value = aws_api_gateway_resource.techx-tf-id-resource.id
}

output "user-resource-id" {
    value = aws_api_gateway_resource.techx-tf-user-resource.id
}