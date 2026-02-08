resource "aws_api_gateway_resource" "techx-tf-user-resource" {
    rest_api_id  = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id
    path_part = "user"
}

resource "aws_api_gateway_method" "techx-tf-user-post-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = "POST"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.techx-tf-authorizers.id
}

resource "aws_api_gateway_method" "techx-tf-user-get-method" {
     rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
     resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
     http_method ="GET"
     authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.techx-tf-authorizers.id
}

resource "aws_api_gateway_method" "techx-tf-user-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
     resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
     http_method = "OPTIONS"
     authorization = "NONE"
}

resource "aws_api_gateway_integration" "techx-tf-user-get-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-get-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-user-post-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-post-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-user-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-options-method.http_method
    type                    = "MOCK"
    content_handling = "CONVERT_TO_TEXT"

    request_templates = {
        "application/json" = jsonencode({"statusCode": 200})
    }
}

resource "aws_api_gateway_method_response" "techx-tf-user-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-options-method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true,
    }

    response_models = {
      "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration_response" "techx-tf-user-options-integration-response" {
    depends_on = [ aws_api_gateway_integration.techx-tf-user-options-integration ]
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-options-method.http_method
    status_code = aws_api_gateway_method_response.techx-tf-user-options-method-response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
        "method.response.header.Access-Control-Allow-Origin"  = "'http://localhost:5173'",
    }
}