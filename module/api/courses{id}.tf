resource "aws_api_gateway_resource" "techx-tf-id-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_resource.techx-tf-courses-resource.id
    path_part   = "{id}"
}

resource "aws_api_gateway_method" "techx-tf-id-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_method" "techx-tf-id-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "techx-tf-id-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-id-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-options-method.http_method
    type = "MOCK"
    content_handling = "CONVERT_TO_TEXT"

    request_templates = {
        "application/json" = jsonencode({"statusCode": 200})
    }
}

resource "aws_api_gateway_method_response" "techx-tf-id-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-options-method.http_method
    status_code = 200

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true,
    }
}

resource "aws_api_gateway_integration_response" "techx-tf-id-options-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_integration.techx-tf-id-options-integration.http_method
    status_code = aws_api_gateway_method_response.techx-tf-id-options-method-response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
        "method.response.header.Access-Control-Allow-Origin"  = "'http://localhost:5173'",
    }
}