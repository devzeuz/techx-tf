resource "aws_api_gateway_rest_api" "techx-tf-api-gateway" {
    name        = "techx-tf-api-gateway"
    description = "API Gateway for TechX Terraform project"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

// API Gateway Resource
resource "aws_api_gateway_resource" "techx-tf-courses-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id // root resource id represent the / part of the rest api
    path_part   = "courses"
}

resource "aws_api_gateway_resource" "techx-tf-id-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_resource.techx-tf-courses-resource.id // root resource id represent the / part of the rest api
    path_part   = "{id}"
}

resource "aws_api_gateway_resource" "techx-tf-user-resource" {
    rest_api_id  = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id
    path_part = "user"
}
// API Gateway Resource

// API resource Methods
resource "aws_api_gateway_method" "techx-tf-courses-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method   = "GET"
    authorization  = "NONE"
}

resource "aws_api_gateway_method" "techx-tf-id-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = "GET"
    authorization = "NONE"
}

        // USER Resource Methods
resource "aws_api_gateway_method" "techx-tf-user-post-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_method" "techx-tf-user-get-method" {
     rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
     resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
     http_method = "GET"
     authorization = "NONE" // NONE is a placeholder, there is actually auth token expected. since access (to DynamoDB) is involved.
}
             // OPTIONS method for /user resource
resource "aws_api_gateway_integration" "techx-tf-user-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = "OPTIONS"
    type                    = "MOCK"
}
// API Resource Methods


// API Method Integration 
resource "aws_api_gateway_integration" "techx-tf-courses-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_method.techx-tf-courses-method.http_method
    integration_http_method = "POST" // API gateway POST the frontend request to lambda therefor invoking it in the process, this is why integration HTTP method is set to post
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-id-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

               // User resource integration for GET and POST method
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
// API Method Integration

// API Deployment => Stage
resource "aws_api_gateway_deployment" "techx-tf-api-deploment" {
    depends_on = [aws_api_gateway_integration.techx-tf-courses-integration] // to make sure the integration is created before deployment
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    
        triggers = {
        redeployment = sha1(jsonencode([
                // /courses resource deployment trigger
                aws_api_gateway_resource.techx-tf-courses-resource.id,
                aws_api_gateway_method.techx-tf-courses-method.id,
                aws_api_gateway_integration.techx-tf-courses-integration.id,

                // /courses/{id} resource deployment trigger
                aws_api_gateway_resource.techx-tf-id-resource.id,
                aws_api_gateway_method.techx-tf-id-method.id,
                aws_api_gateway_integration.techx-tf-id-integration.id,

                // /user resource deployment trigger
                aws_api_gateway_resource.techx-tf-user-resource.id,
                aws_api_gateway_method.techx-tf-user-post-method.id,
                aws_api_gateway_integration.techx-tf-user-post-integration.id,
                aws_api_gateway_method.techx-tf-user-get-method.id,
                aws_api_gateway_integration.techx-tf-user-get-integration.id,
                aws_api_gateway_integration.techx-tf-user-options-integration.id,
            ]))
        }

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "techx-tf-api-stage" {
 deployment_id = aws_api_gateway_deployment.techx-tf-api-deploment.id
  rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
  stage_name    = "dev"
}