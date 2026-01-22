resource "aws_api_gateway_rest_api" "techx-tf-api-gateway" {
    name        = "techx-tf-api-gateway"
    description = "API Gateway for TechX Terraform project"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "techx-tf-courses-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id // root resource id represent the / aprt of the rest api
    path_part   = "courses"
}

output "root_resource_id"{
    value = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id
}

output "restApi_id"{
    value = aws_api_gateway_rest_api.techx-tf-api-gateway.id
}

resource "aws_api_gateway_method" "techx-tf-courses-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method   = "GET"
    authorization  = "NONE"

    // I will be getting the source ARN from this method, that goes in the lambda permission.
}

resource "aws_api_gateway_integration" "techx-tf-courses-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_method.techx-tf-courses-method.http_method
    integration_http_method = "POST" // API gateway POST the frontend request to lambda therefor invoking it in the process
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}