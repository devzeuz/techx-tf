resource "aws_api_gateway_authorizer" "techx-tf-authorizers" {
    name = "techx-tf-cognito-authorizer"
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    type = "COGNITO_USER_POOLS"
    provider_arns = [var.cognito-user-pool-arn] // Why do i have to make the arn an object?
    identity_source = "method.request.header.Authorization" // Figure out why this is mapped this way.
}