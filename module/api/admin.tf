resource "aws_api_gateway_resource" "techx-tf-admin-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id // Simply just saying it belong under the / resource*
    path_part   = "admin"
}

resource "aws_api_gateway_resource" "techx-tf-ingest-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_resource.techx-tf-admin-resource.id
    path_part   = "ingest"
}

resource "aws_api_gateway_method" "techx-tf-ingest-post-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = "POST"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.techx-tf-authorizers.id
}

resource "aws_api_gateway_integration" "techx-tf-ingest-post-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = aws_api_gateway_method.techx-tf-ingest-post-method.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = var.ingest-lambda-invoke-arn
}

resource "aws_api_gateway_method" "techx-tf-ingest-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "techx-tf-ingest-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = aws_api_gateway_method.techx-tf-ingest-options-method.http_method
    type = "MOCK"
}

resource "aws_api_gateway_method_response" "techx-tf-ingest-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = aws_api_gateway_integration.techx-tf-ingest-options-integration.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "techx-tf-ingest-options-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-ingest-resource.id
    http_method = aws_api_gateway_integration.techx-tf-ingest-options-integration.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'POST'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
}